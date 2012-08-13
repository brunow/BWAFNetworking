//
//  ListsViewController.m
//  BWAFNetworkingExample
//
//  Created by cesar4 on 13/08/12.
//  Copyright (c) 2012 brunow. All rights reserved.
//

#import "ListsViewController.h"

#import "List.h"
#import "HttpClient.h"
#import "CoreData+MagicalRecord.h"
#import "NotesViewController.h"

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@interface ListsViewController ()

@end

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation ListsViewController


////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
    }
    return self;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UITextField *textField = [self creationTextField];
    self.tableView.tableHeaderView = textField;
    
    [self loadLists];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidUnload {
    [super viewDidUnload];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    __weak ListsViewController *weakRef = self;
    [[HttpClient sharedClient] allObjects:[List class] success:^(NSArray *objects) {
        [weakRef loadLists];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        
    }];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadLists {
    self.items = [NSMutableArray arrayWithArray:[List MR_findAll]];
    [self.tableView reloadData];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.items count];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    List *list = [self.items objectAtIndex:indexPath.row];
    
    cell.textLabel.text = list.title;
    
    return cell;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        List *list = [self.items objectAtIndex:indexPath.row];
        [[HttpClient sharedClient] deleteObject:list success:nil failure:nil];
        [self.items removeObject:list];
        [list MR_deleteEntity];
        [list.managedObjectContext MR_saveNestedContexts];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}


#pragma mark - Table view delegate


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    List *list = [self.items objectAtIndex:indexPath.row];
    NotesViewController *vc = [[NotesViewController alloc] initWithList:list];
    [self.navigationController pushViewController:vc animated:YES];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITextFieldDelegate


////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    __weak ListsViewController *weakRef = self;
    List *list = [List MR_createEntity];
    list.title = textField.text;
    [[HttpClient sharedClient] postObject:list success:^(id object) {
        [weakRef loadLists];
        
    } failure:nil];
    
    [textField resignFirstResponder];
    textField.text = nil;
    
    return YES;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


////////////////////////////////////////////////////////////////////////////////////////////////////
- (UITextField *)creationTextField {
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 30)];
    textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    textField.delegate = self;
    textField.placeholder = @"List title";
    textField.borderStyle = UITextBorderStyleRoundedRect;
    return textField;
}


@end
