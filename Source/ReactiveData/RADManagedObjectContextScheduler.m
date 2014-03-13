//
//  RADManagedObjectContextScheduler.h
//  ReactiveData
//
//  Created by Denis Mikhaylov on 22/11/13.
//
//

#import "RADManagedObjectContextScheduler.h"
#import <ReactiveCocoa/RACQueueScheduler+Subclass.h>

@implementation NSManagedObjectContext (SchedulerHelper)
- (RACDisposable *)schedule:(void (^)(void))block
{
	if (self.concurrencyType == NSMainQueueConcurrencyType && [NSThread isMainThread]) {
		block();
		return nil;
	}
	
	if (![NSThread isMainThread]) {
		[self performBlock:block];
		return nil;
	}
	
	RACDisposable *disposable = [[RACDisposable alloc] init];
	[self performBlock:^{
		if (disposable.isDisposed) return;
		block();
	}];
	return disposable;
}
@end

@interface RADManagedObjectContextScheduler ()
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) RACScheduler *internalScheduler;
@end


@implementation RADManagedObjectContextScheduler
- (id)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
	NSParameterAssert(managedObjectContext.concurrencyType != NSConfinementConcurrencyType);
    self = [super init];
    if (self) {
        _managedObjectContext = managedObjectContext;
		_internalScheduler = [RACQueueScheduler schedulerWithPriority:RACSchedulerPriorityDefault];
    }
    return self;
}

- (RACDisposable *)schedule:(void (^)(void))block {
	return [self.managedObjectContext schedule:block];
}

- (RACDisposable *)after:(NSDate *)date schedule:(void (^)(void))block {
	RACSerialDisposable *disposable = [[RACSerialDisposable alloc] init];;
	disposable.disposable = [self.internalScheduler after:date schedule:^{
		if (disposable.isDisposed) return;
		disposable.disposable = [self schedule:block];
	}];
	return disposable;
}



- (RACDisposable *)after:(NSDate *)date repeatingEvery:(NSTimeInterval)interval withLeeway:(NSTimeInterval)leeway schedule:(void (^)(void))block {
	RACSerialDisposable *disposable = [[RACSerialDisposable alloc] init];;
	disposable.disposable = [self.internalScheduler after:date repeatingEvery:interval withLeeway:leeway schedule:^{
		if (disposable.isDisposed) return;
		disposable.disposable = [self schedule:block];
	}];
	return disposable;
}
@end

@implementation NSManagedObjectContext (Scheduler)
- (RACScheduler *)scheduler
{
    if (!self.userInfo[@"scheduler"])
        self.userInfo[@"scheduler"] = [[RADManagedObjectContextScheduler alloc] initWithManagedObjectContext:self];
    return self.userInfo[@"scheduler"];
}
@end
