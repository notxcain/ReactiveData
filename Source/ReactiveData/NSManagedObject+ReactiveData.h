//
//  NSManagedObject+ReactiveData.h
//  ReactiveData
//
//  Created by Denis Mikhaylov on 02/12/13.
//  Copyright (c) 2013 QIWI. All rights reserved.
//

#import <CoreData/CoreData.h>

@class RACSignal;
@protocol RADFetchRequestFactory;
@interface NSManagedObject (ReactiveData)
+ (RACSignal *)rad_findAllInContext:(NSManagedObjectContext *)context;

+ (RACSignal *)rad_findAllWithPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context;

+ (RACSignal *)rad_findFirstInContext:(NSManagedObjectContext *)context;
+ (RACSignal *)rad_findFirstWithPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context;

+ (RACSignal *)rad_findFirstByAttribute:(NSString *)attribute withValue:(id)searchValue inContext:(NSManagedObjectContext *)context;

+ (id <RADFetchRequestFactory>)rad_requestFor;

+ (NSEntityDescription *)rad_entityDescriptionInContext:(NSManagedObjectContext *)context;
+ (instancetype)rad_createInContext:(NSManagedObjectContext *)context;
+ (RACSignal *)rad_deleteAllMatchingPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context;
+ (RACSignal *)rad_truncateAllInContext:(NSManagedObjectContext *)context;
- (RACSignal *)rad_inContext:(NSManagedObjectContext *)otherContext;

- (void)rad_delete;
@end

@protocol RADFetchRequestFactory <NSObject>
- (NSFetchRequest *)all;
- (NSFetchRequest *)allWithPredicate:(NSPredicate *)searchTerm;
- (NSFetchRequest *)allWhere:(NSString *)property isEqualTo:(id)value;
- (NSFetchRequest *)firstWithPredicate:(NSPredicate *)searchTerm;
- (NSFetchRequest *)firstByAttribute:(NSString *)attribute withValue:(id)searchValue;
- (NSFetchRequest *)allSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending;
- (NSFetchRequest *)allSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending withPredicate:(NSPredicate *)searchTerm;
@end