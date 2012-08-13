//
//  AppDelegate.m
//  BWAFNetworkingExample
//
//  Created by cesar4 on 13/08/12.
//  Copyright (c) 2012 brunow. All rights reserved.
//

#import "AppDelegate.h"

#import "BWObjectMapper.h"
#import "BWObjectSerializer.h"
#import "BWObjectRouter.h"
#import "CoreData+MagicalRecord.h"

#import "List.h"
#import "Note.h"
#import "ListsViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [MagicalRecord setupAutoMigratingCoreDataStack];
    
    [self initializeObjectSerializer];
    [self initializeRoutes];
    [self initializeObjectMapping];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    ListsViewController *vc = [[ListsViewController alloc] init];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    
    self.window.rootViewController = nc;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)initializeObjectSerializer {
    [BWObjectSerializerMapping mappingForObject:[List class] block:^(BWObjectSerializerMapping *serializer) {
        [serializer mapKeyPath:@"title" toAttribute:@"title"];
        
        [[BWObjectSerializer shared] registerSerializer:serializer withRootKeyPath:@"list"];
    }];
    
    [BWObjectSerializerMapping mappingForObject:[Note class] block:^(BWObjectSerializerMapping *serializer) {
        [serializer mapKeyPath:@"title" toAttribute:@"title"];
        [serializer mapKeyPath:@"content" toAttribute:@"content"];
        
        [[BWObjectSerializer shared] registerSerializer:serializer withRootKeyPath:@"note"];
    }];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)initializeObjectMapping {
    [BWObjectMapping mappingForObject:[List class] block:^(BWObjectMapping *mapping) {
        [mapping mapPrimaryKeyAttribute:@"id" toAttribute:@"listID"];
        [mapping mapKeyPath:@"title" toAttribute:@"title"];
        [mapping mapKeyPath:@"created_at" toAttribute:@"createdAt"];
        [mapping mapKeyPath:@"updated_at" toAttribute:@"updatedAt"];
        
        [[BWObjectMapper shared] registerMapping:mapping withRootKeyPath:nil];
    }];
    
    [BWObjectMapping mappingForObject:[Note class] block:^(BWObjectMapping *mapping) {
        [mapping mapPrimaryKeyAttribute:@"id" toAttribute:@"noteID"];
        [mapping mapKeyPath:@"title" toAttribute:@"title"];
        [mapping mapKeyPath:@"content" toAttribute:@"content"];
        [mapping mapKeyPath:@"created_at" toAttribute:@"createdAt"];
        [mapping mapKeyPath:@"updated_at" toAttribute:@"updatedAt"];
        [mapping mapKeyPath:@"list_id" toAttribute:@"list" valueBlock:^id(id value, id object) {
            Note *note = [List MR_findFirstByAttribute:@"listID" withValue:value];
            
            if (nil == note) {
                note = [List MR_createEntity];
                note.noteID = value;
            }
            
            return note;
        }];
        
        [[BWObjectMapper shared] registerMapping:mapping withRootKeyPath:nil];
    }];
    
    [[BWObjectMapper shared] objectWithBlock:^id(Class objectClass, NSString *primaryKey, id primaryKeyValue, id JSON) {
        NSManagedObject *object = [objectClass MR_findFirstByAttribute:primaryKey withValue:primaryKeyValue];
        
        if (nil == object)
            object = [objectClass MR_createEntity];
        
        return object;
    }];
    
    [[BWObjectMapper shared] didMapObjectWithBlock:^void(NSManagedObject *object) {
        [object.managedObjectContext MR_saveNestedContexts];
    }];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)initializeRoutes {
    [[BWObjectRouter shared] routeObjectClass:[List class]
                               toResourcePath:@"/lists/:listID"
                                    forMethod:BWObjectRouterMethodAllExceptPOST];
    
    [[BWObjectRouter shared] routeObjectClass:[List class]
                               toResourcePath:@"/lists/"
                                    forMethod:BWObjectRouterMethodINDEX];
    
    [[BWObjectRouter shared] routeObjectClass:[List class]
                               toResourcePath:@"/lists"
                                    forMethod:BWObjectRouterMethodPOST];
    
    
    
    [[BWObjectRouter shared] routeObjectClass:[Note class]
                               toResourcePath:@"/lists/:listID/notes"
                                    forMethod:BWObjectRouterMethodINDEX];
    
    [[BWObjectRouter shared] routeObjectClass:[Note class]
                               toResourcePath:@"/lists/:list.listID/notes/:noteID"
                                    forMethod:BWObjectRouterMethodAllExceptPOST];
    
    [[BWObjectRouter shared] routeObjectClass:[Note class]
                               toResourcePath:@"/lists/:list.listID/notes/"
                                    forMethod:BWObjectRouterMethodPOST];
}


@end
