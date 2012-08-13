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

#import "BWAFOAuth2Client.h"


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BWAFOAuth2Client


////////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)sharedClient {
    static BWAFOAuth2Client *_sharedClient = nil;
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
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark OAuth2


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)authenticateUsingOAuthWithPath:(NSString *)path
                              username:(NSString *)username
                              password:(NSString *)password
                              clientID:(NSString *)clientID 
                                secret:(NSString *)secret 
                               success:(void (^)(AFOAuthAccount *account))success 
                               failure:(void (^)(NSError *error))failure {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:@"password" forKey:@"grant_type"];
    [parameters setObject:clientID forKey:@"client_id"];
    [parameters setObject:secret forKey:@"client_secret"];
    [parameters setObject:username forKey:@"username"];
    [parameters setObject:password forKey:@"password"];
    
    [self authenticateUsingOAuthWithPath:path parameters:parameters success:success failure:failure];
}


@end
