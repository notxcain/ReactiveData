//
//  RADFetchRequestFactory.m
//  ReactiveData
//
//  Created by Denis Mikhaylov on 02/12/13.
//  Copyright (c) 2013 QIWI. All rights reserved.
//

#import "RADFetchRequestGenerator.h"

@interface RADFetchRequestGenerator ()
@property (nonatomic, strong, readonly) NSString *entityName;
@end

@implementation RADFetchRequestGenerator
- (id)initWithEntityName:(NSString *)entityName
{
    self = [super init];
    if (self) {
		_entityName = [entityName copy];
    }
    return self;
}

- (NSFetchRequest *)createFetchRequest
{
    return [NSFetchRequest fetchRequestWithEntityName:self.entityName];
}

- (NSFetchRequest *)all
{
	return [self createFetchRequest];
}

- (NSFetchRequest *)allWithPredicate:(NSPredicate *)searchTerm
{
    NSFetchRequest *request = [self createFetchRequest];
    [request setPredicate:searchTerm];
    
    return request;
}

- (NSFetchRequest *)allWhere:(NSString *)property isEqualTo:(id)value
{
    NSFetchRequest *request = [self createFetchRequest];
    [request setPredicate:[NSPredicate predicateWithFormat:@"%K = %@", property, value]];
    
    return request;
}

- (NSFetchRequest *)firstWithPredicate:(NSPredicate *)searchTerm
{
    NSFetchRequest *request = [self createFetchRequest];
    [request setPredicate:searchTerm];
    [request setFetchLimit:1];
    
    return request;
}

- (NSFetchRequest *)firstByAttribute:(NSString *)attribute withValue:(id)searchValue;
{
    NSFetchRequest *request = [self allWhere:attribute isEqualTo:searchValue];
    [request setFetchLimit:1];
    return request;
}

- (NSFetchRequest *)allSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending
{
    return [self allSortedBy:sortTerm ascending:ascending withPredicate:nil];
}

- (NSFetchRequest *)allSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending withPredicate:(NSPredicate *)searchTerm
{
	NSFetchRequest *request = [self all];
	if (searchTerm)
    {
        [request setPredicate:searchTerm];
    }
	[request setFetchBatchSize:20];
	
    NSMutableArray* sortDescriptors = [[NSMutableArray alloc] init];
    NSArray* sortKeys = [sortTerm componentsSeparatedByString:@","];
    for (__strong NSString* sortKey in sortKeys)
    {
        NSArray * sortComponents = [sortKey componentsSeparatedByString:@":"];
        if (sortComponents.count > 1)
		{
			NSNumber * customAscending = sortComponents.lastObject;
			ascending = customAscending.boolValue;
			sortKey = sortComponents[0];
		}
		
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending];
        [sortDescriptors addObject:sortDescriptor];
    }
    
	[request setSortDescriptors:sortDescriptors];
    
	return request;
}

@end
