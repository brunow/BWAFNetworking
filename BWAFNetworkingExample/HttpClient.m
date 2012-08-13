//
//  HttpClient.m
//  BWAFNetworkingExample
//
//  Created by cesar4 on 13/08/12.
//  Copyright (c) 2012 brunow. All rights reserved.
//

#import "HttpClient.h"

#define SERVER_URL @"http://localhost:3000"

@implementation HttpClient


////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSURL *)baseURL {
    return [NSURL URLWithString:SERVER_URL];
}


@end
