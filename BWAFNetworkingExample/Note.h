//
//  Note.h
//  BWAFNetworkingExample
//
//  Created by cesar4 on 13/08/12.
//  Copyright (c) 2012 brunow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class List;

@interface Note : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSNumber * noteID;
@property (nonatomic, retain) List *list;

@end
