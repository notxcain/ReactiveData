ReactiveData
============

ReactiveData is a mixture of RAC and CoreData

```objc
NSManagedObjectContext *context = ...main thread context...
NSManagedObjectContext *importContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
importContext.parentContext = context;
RACSignal *updateSignal =  
[[[[[[APIClient requestPosts] 
deliverOn:[importContext scheduler]] //Delivers next on context private queue
map:^(NSArray *dictionaries) {
  NSArray *objectIDs = [dictionaries map:^(id obj) {
  Post *post = [Post createWithDictionary:obj inContext:importContext];
    return post.objectID;
  }];
  return [[importContext rad_save] concat:[RACSignal return:objectIDs]]; //Saves asynchronously
}] 
switchToLatest]
deliverOn:[context scheduler]] 
map:^(NSArray *objectIDs) {
  return [self rad_findAllWithPredicate:[NSPredicate predicateWithFormat:@"self IN %@", objectIDs] inContext:context];
}] 
switchToLatest];
```
