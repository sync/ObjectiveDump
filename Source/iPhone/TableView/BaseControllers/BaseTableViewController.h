//
//  BaseTableViewController.h
//  
//
//  Created by Anthony Mittaz on 5/02/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BaseTableViewController : UITableViewController <UIAlertViewDelegate>{
	ObjectiveDumpAppDelegate *_appDelegate;
	
	NSMutableArray *_content;
	
	NSString *_dumpedFilePath;
}

@property (nonatomic, readonly) ObjectiveDumpAppDelegate *appDelegate;
@property (nonatomic, readonly) Class cellClass;
@property (nonatomic, readonly) UITableViewCellStyle cellStyle;
@property (nonatomic, readonly) NSMutableArray *content;
@property (nonatomic, copy) NSString *dumpedFilePath;

// Setting up 
- (void)setupTableView;
- (void)setupNavigationBar;
- (void)setupToolbar;

// Cell properties
- (Class)cellClass;
- (NSDictionary *)attributesForCell:(UITableViewCell *)cell withObject:(id)object;

// Retrieve object linked to row
- (id)objectForIndexPath:(NSIndexPath *)indexPath;

// Restore levels
- (void)restoreLevelWithSelectionArray:(NSArray *)selectionArray;

// Show error to user
// Cannot cancel, just ok button
- (void)showUserErrorWithTitle:(NSString *)title message:(NSString *)message;

// Show loading view
// Possiblity to add a message
// Like loading...
- (void)showLoadingView:(BOOL)show withText:(NSString *)text;

@end
