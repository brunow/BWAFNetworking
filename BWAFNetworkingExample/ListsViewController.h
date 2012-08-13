//
//  ListsViewController.h
//  BWAFNetworkingExample
//
//  Created by cesar4 on 13/08/12.
//  Copyright (c) 2012 brunow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListsViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, strong) NSMutableArray *items;

@end
