//
//  NSManagedObject+ReactiveData.m
//  ReactiveData
//
//  Created by Denis Mikhaylov on 02/12/13.
//  Copyright (c) 2013 QIWI. All rights reserved.
//

#import "NSManagedObject+ReactiveData.h"
#import "NSManagedObjectContext+ReactiveData.h"
#import "RADFetchRequestGenerator.h"
#import "NSManagedObjectContext+ReactiveData.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation NSManagedObject (ReactiveData)

+ (RACSignal *)rad_findAllInContext:(NSManagedObjectContext *)context
{
	return [context rad_executeFetchRequest:[[self rad_requestFor] all]];
}


+ (RACSignal *)rad_findAllWithPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context
{
	NSFetchRequest *request = [[self rad_requestFor] allWithPredicate:searchTerm];
	return [context rad_executeFetchRequest:request];
}

+ (RACSignal *)rad_findFirstInContext:(NSManagedObjectContext *)context
{
	NSFetchRequest *request = [[self rad_requestFor] all];
	
	return [context rad_executeFetchRequestAndReturnFirstObject:request];
}

+ (RACSignal *)rad_findFirstByAttribute:(NSString *)attribute withValue:(id)searchValue inContext:(NSManagedObjectContext *)context
{
	NSFetchRequest *request = [[self rad_requestFor] firstByAttribute:attribute withValue:searchValue];
	[request setPropertiesToFetch:[NSArray arrayWithObject:attribute]];
    
	return [context rad_executeFetchRequestAndReturnFirstObject:request];
}



+ (RACSignal *)rad_findFirstWithPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[self rad_requestFor] firstWithPredicate:searchTerm];
    
    return [context rad_executeFetchRequestAndReturnFirstObject:request];
}

+ (id<RADFetchRequestGenerator>)rad_requestFor;
{
	return [[RADFetchRequestGenerator alloc] initWithEntityName:[self rad_bestGuessAtAnEntityName]];
}

+ (NSString *)rad_bestGuessAtAnEntityName
{
    return NSStringFromClass(self);
}

+ (NSEntityDescription *)rad_entityDescriptionInContext:(NSManagedObjectContext *)context
{
    NSString *entityName = [self rad_bestGuessAtAnEntityName];
    return [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
}

+ (NSArray *)rad_sortAscending:(BOOL)ascending attributes:(NSArray *)attributesToSortBy
{
	NSMutableArray *attributes = [NSMutableArray array];
    
    for (NSString *attributeName in attributesToSortBy)
    {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:attributeName ascending:ascending];
        [attributes addObject:sortDescriptor];
    }
    
	return attributes;
}

+ (NSArray *)rad_ascendingSortDescriptors:(NSArray *)attributesToSortBy
{
	return [self rad_sortAscending:YES attributes:attributesToSortBy];
}

+ (NSArray *)rad_descendingSortDescriptors:(NSArray *)attributesToSortBy
{
	return [self rad_sortAscending:NO attributes:attributesToSortBy];
}

#pragma mark -

+ (id)rad_createInContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self rad_bestGuessAtAnEntityName] inManagedObjectContext:context];
}

- (void)rad_delete
{
	[self.managedObjectContext deleteObject:self];
}

+ (RACSignal *)rad_deleteAllMatchingPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[self rad_requestFor] allWithPredicate:predicate];
    [request setReturnsObjectsAsFaults:YES];
	[request setIncludesPropertyValues:NO];
    
	return [[[[context rad_executeFetchRequest:request] doNext:^(NSArray *objectsToTruncate) {
		for (id objectToTruncate in objectsToTruncate) {
			[objectToTruncate rad_delete];
		}
	}] mapReplace:[RACSignal empty]] switchToLatest];
}

+ (RACSignal *)rad_truncateAllInContext:(NSManagedObjectContext *)context
{
    return [self rad_deleteAllMatchingPredicate:nil inContext:context];
}

- (RACSignal *)rad_inContext:(NSManagedObjectContext *)otherContext
{
	return [[self.managedObjectContext rad_obtainPermanentIDsForObjects:@[self]] flattenMap:^RACStream *(NSArray *permanentObjectIDs) {
        return [otherContext rad_existingObjectWithID:permanentObjectIDs.firstObject];
    }];
}
@end
