//
//  RADManagedObjectContextScheduler.h
//  ReactiveData
//
//  Created by Denis Mikhaylov on 22/11/13.
//
//

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <CoreData/CoreData.h>

@interface RADManagedObjectContextScheduler : RACScheduler
@end

@interface NSManagedObjectContext (Scheduler)
- (RACScheduler *)scheduler;
@end
