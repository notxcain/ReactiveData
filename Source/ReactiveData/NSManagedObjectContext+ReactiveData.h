//
//  NSManagedObjectContext+ReactiveData.h
//  ReactiveData
//
//  Created by Denis Mikhaylov on 02/12/13.
//  Copyright (c) 2013 QIWI. All rights reserved.
//

#import <CoreData/CoreData.h>

@class RACSignal;
@interface NSManagedObjectContext (ReactiveData)
+ (instancetype)contextWithParent:(NSManagedObjectContext *)parentContext;

/// Returns a signal thar either completes on success or errors.
- (RACSignal *)rad_save;
- (RACSignal *)rad_saveToPersistentStore;

- (RACSignal *)rad_executeFetchRequest:(NSFetchRequest *)request;
- (RACSignal *)rad_executeFetchRequestAndReturnFirstObject:(NSFetchRequest *)request;
- (RACSignal *)rad_existingObjectWithID:(NSManagedObjectID *)objectID;
- (RACSignal *)rad_countForFetchRequest:(NSFetchRequest *)request;
- (RACSignal *)rad_obtainPermanentIDsForObjects:(NSArray *)objects;
@end
