//
//  NSManagedObjectContext+ReactiveData.m
//  ReactiveData
//
//  Created by Denis Mikhaylov on 02/12/13.
//  Copyright (c) 2013 QIWI. All rights reserved.
//

#import "NSManagedObjectContext+ReactiveData.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "RADManagedObjectContextScheduler.h"

@implementation NSManagedObjectContext (MagicalSaves)
+ (instancetype)contextWithParent:(NSManagedObjectContext *)parentContext
{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    context.parentContext = parentContext;
    return context;
}

- (RACSignal *)rad_executeFetchRequest:(NSFetchRequest *)request
{
	return [[[RACSignal return:request] deliverOn:[self scheduler]] tryMap:^(id value, NSError *__autoreleasing *errorPtr) {
        return [self executeFetchRequest:request error:errorPtr];
    }];
}

- (RACSignal *)rad_executeFetchRequestAndReturnFirstObject:(NSFetchRequest *)request
{
	return [RACSignal defer:^{
		[request setFetchLimit:1];
		return [[self rad_executeFetchRequest:request] map:^(NSArray *results) {
			return [results firstObject];
		}];
	}];
}

- (RACSignal *)rad_save
{
    return [RACSignal createSignal:^(id<RACSubscriber> subscriber) {
		RACDisposable *disposable = [[RACDisposable alloc] init];
		[self performBlock:^{
			if ([disposable isDisposed]) return;
			NSError *error;
			if ([self save:&error]) {
				[subscriber sendCompleted];
			} else {
				[subscriber sendError:error];
			}
		}];
		return disposable;
	}];
}

- (RACSignal *)rad_saveToPersistentStore
{
	return [[self rad_save] concat:(self.parentContext ? [self.parentContext rad_saveToPersistentStore] : [RACSignal empty])];
}
@end
