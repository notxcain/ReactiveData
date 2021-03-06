//
//  RADFetchRequestFactory.h
//  ReactiveData
//
//  Created by Denis Mikhaylov on 02/12/13.
//  Copyright (c) 2013 QIWI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSManagedObject+ReactiveData.h"

@interface RADFetchRequestGenerator : NSObject <RADFetchRequestGenerator>
- (id)initWithEntityName:(NSString *)entityName;
@end
