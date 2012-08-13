//
//  NotesViewController.m
//  BWAFNetworkingExample
//
//  Created by cesar4 on 13/08/12.
//  Copyright (c) 2012 brunow. All rights reserved.
//

#import "NotesViewController.h"

#import "List.h"
#import "Note.h"
#import "HttpClient.h"
#import "CoreData+MagicalRecord.h"

@interface NotesViewController ()

@end

@implementation NotesViewController


////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithList:(List *)list {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.list = list;
    }
    return self;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UITextField *textField = [self creationTextField];
    self.tableView.tableHeaderView = textField;
    
    [self loadNotes];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidUnload {
    [super viewDidUnload];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    __weak NotesViewController *weakRef = self;
    [[HttpClient sharedClient] allObjects:[Note class] fromObject:self.list success:^(NSArray *objects) {
        [weakRef loadNotes];
        
    } failure:nil];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadNotes {
    self.items = [NSMutableArray arrayWithArray:[[self.list notes] allObjects]];
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
    
    Note *note = [self.items objectAtIndex:indexPath.row];
    
    cell.textLabel.text = note.title;
    
    return cell;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Note *note = [self.items objectAtIndex:indexPath.row];
        [[HttpClient sharedClient] deleteObject:note success:nil failure:nil];
        [self.items removeObject:note];
        [note MR_deleteEntity];
        [note.managedObjectContext MR_saveNestedContexts];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}


#pragma mark - Table view delegate


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITextFieldDelegate


////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    __weak NotesViewController *weakRef = self;
    Note *note = [Note MR_createEntity];
    note.list = self.list;
    note.title = textField.text;
    [[HttpClient sharedClient] postObject:note success:^(id object) {
        [weakRef loadNotes];
        
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
    textField.placeholder = @"Note title";
    textField.borderStyle = UITextBorderStyleRoundedRect;
    return textField;
}


@end
