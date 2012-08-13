//
//  NotesViewController.h
//  BWAFNetworkingExample
//
//  Created by cesar4 on 13/08/12.
//  Copyright (c) 2012 brunow. All rights reserved.
//

#import <UIKit/UIKit.h>

@class List;

@interface NotesViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) List *list;

- (id)initWithList:(List *)list;

@end
