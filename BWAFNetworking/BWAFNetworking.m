//
// Created by Bruno Wernimont on 2012
// Copyright 2012 BWAFNetworking
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "BWAFNetworking.h"

#import "BWObjectRouter.h"
#import "BWObjectSerializer.h"
#import "BWObjectMapper.h"

typedef id (^BWAFResultReturnBlock)(void);
typedef void (^BWAFResultBlock)(id result);

static dispatch_queue_t bwaf_parsing_operation_queue;
static dispatch_queue_t parsing_operation_queue() {
    if (bwaf_parsing_operation_queue == NULL) {
        bwaf_parsing_operation_queue = dispatch_queue_create("com.bwafnetworking.parsing", 0);
    }
    
    return bwaf_parsing_operation_queue;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@interface BWAFNetworking ()

- (NSString *)fullPath:(NSString *)path;

- (NSDictionary *)paramsWithParams:(NSDictionary *)params;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BWAFNetworking


////////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)sharedClient {
    static BWAFNetworking *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] initWithBaseURL:nil];
    });
    
    return _sharedClient;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSURL *)baseURL {
    return nil;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)path {
    return nil;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSDictionary *)params {
    return nil;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:[self baseURL]];
    if (self) {
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        self.parameterEncoding = AFFormURLParameterEncoding;
    }
    return self;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)allObjects:(Class)objectClass
           success:(BWAFNetworkingAllObjectsSuccessBlock)success
           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    [self allObjects:objectClass fromObject:nil params:nil success:success failure:failure];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)allObjects:(Class)objectClass
            params:(NSDictionary *)params
           success:(BWAFNetworkingAllObjectsSuccessBlock)success
           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    [self allObjects:objectClass fromObject:nil params:params success:success failure:failure];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)allObjects:(Class)objectClass
        fromObject:(id)object
           success:(BWAFNetworkingAllObjectsSuccessBlock)success
           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    [self allObjects:objectClass fromObject:object params:nil success:success failure:failure];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)allObjects:(Class)objectClass
        fromObject:(id)object
            params:(NSDictionary *)params
           success:(BWAFNetworkingAllObjectsSuccessBlock)success
           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    NSString *path = nil;
    
    if (nil == object) {
        path = [[BWObjectRouter shared] resourcePathForMethod:BWObjectRouterMethodINDEX
                                              withObjectClass:objectClass];
    } else {
        path = [[BWObjectRouter shared] resourcePathForMethod:BWObjectRouterMethodINDEX
                                              withObjectClass:objectClass
                                                  valueObject:object];
    }
    
    [self getPath:path
       parameters:(params != nil) ? [self paramsWithParams:params] : [self params]
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              [self performResultBlockInBackground:^id(){
                  NSArray *objectsFromJSON = [[BWObjectMapper shared] objectsFromJSON:responseObject
                                                                      withObjectClass:objectClass];
                  return objectsFromJSON;
                  
              } completion:^(id result) {
                  if (nil != success)
                      success(result);
              }];
              
          } failure:failure];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)postObject:(id)object
           success:(BWAFNetworkingObjectSuccessBlock)success
           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    NSString *path = [[BWObjectRouter shared] resourcePathForMethod:BWObjectRouterMethodPOST
                                                         withObject:object];
    
    NSDictionary *params = [[BWObjectSerializer shared] serializeObject:object];
    
    [self postPath:path
        parameters:[self paramsWithParams:params]
           success:^(AFHTTPRequestOperation *operation, id responseObject) {
               
               [self performResultBlockInBackground:^id{
                   id objectFromJSON = [[BWObjectMapper shared] objectFromJSON:responseObject
                                                               withObjectClass:[object class]
                                                                existingObject:object];
                   return objectFromJSON;
               } completion:^(id result) {
                   if (nil != success)
                       success(result);
               }];
               
           } failure:failure];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)deleteObject:(id)object
             success:(BWAFNetworkingObjectSuccessBlock)success
             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    NSString *path = [[BWObjectRouter shared] resourcePathForMethod:BWObjectRouterMethodDELETE
                                                         withObject:object];
    
    [self deletePath:path
          parameters:[self params]
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 if (nil != self.successDeleteBlock)
                     self.successDeleteBlock(object);
                 
                 if (nil != success)
                     success(object);
                 
             } failure:failure];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)getObject:(id)object
          success:(BWAFNetworkingObjectSuccessBlock)success
          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    NSString *path = [[BWObjectRouter shared] resourcePathForMethod:BWObjectRouterMethodGET
                                                         withObject:object];
    
    [self getPath:path
       parameters:[self params]
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              [self performResultBlockInBackground:^id{
                  id objectFromJSON = [[BWObjectMapper shared] objectFromJSON:responseObject
                                                              withObjectClass:[object class]
                                                               existingObject:object];
                  return objectFromJSON;
              } completion:^(id result) {
                  if (nil != success)
                      success(result);
              }];
              
          } failure:failure];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)putObject:(id)object
          success:(BWAFNetworkingObjectSuccessBlock)success
          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    NSString *path = [[BWObjectRouter shared] resourcePathForMethod:BWObjectRouterMethodPUT
                                                         withObject:object];
    
    NSDictionary *params = [[BWObjectSerializer shared] serializeObject:object];
    
    [self putPath:path
       parameters:[self paramsWithParams:params]
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              [self performResultBlockInBackground:^id{
                  id objectFromJSON = [[BWObjectMapper shared] objectFromJSON:responseObject
                                                              withObjectClass:[object class]
                                                               existingObject:object];
                  return objectFromJSON;
              } completion:^(id result) {
                  if (nil != success)
                      success(result);
              }];
              
          } failure:failure];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark AFHTTPClient


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)getPath:(NSString *)path
     parameters:(NSDictionary *)parameters
        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    [super getPath:[self fullPath:path]
        parameters:[self paramsWithParams:parameters]
           success:success
           failure:failure];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)postPath:(NSString *)path
      parameters:(NSDictionary *)parameters
         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    [super postPath:[self fullPath:path]
         parameters:[self paramsWithParams:parameters]
            success:success
            failure:failure];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)putPath:(NSString *)path
     parameters:(NSDictionary *)parameters
        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    [super putPath:[self fullPath:path]
        parameters:[self paramsWithParams:parameters]
           success:success
           failure:failure];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)deletePath:(NSString *)path
        parameters:(NSDictionary *)parameters
           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    [super deletePath:[self fullPath:path]
           parameters:[self paramsWithParams:parameters]
              success:success
              failure:failure];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)fullPath:(NSString *)path {
    if (nil == [self path]) {
        return path;
    }
    
    return [NSString stringWithFormat:@"%@%@", [self path], path];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSDictionary *)paramsWithParams:(NSDictionary *)params {
    NSMutableDictionary *allParams = [NSMutableDictionary dictionary];
    [allParams addEntriesFromDictionary:params];
    [allParams addEntriesFromDictionary:[self params]];
    
    return allParams;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)performResultBlockInBackground:(BWAFResultReturnBlock)block completion:(BWAFResultBlock)completion {
    dispatch_queue_t background_queue = parsing_operation_queue();
    
    dispatch_async(background_queue, ^{
        id result = block();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(result);
        });

    });
}


@end
