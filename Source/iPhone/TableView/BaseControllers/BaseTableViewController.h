//
//  BaseTableViewController.h
//  
//
//  Created by Anthony Mittaz on 5/02/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BaseTableViewController : UITableViewController {
	ObjectiveDumpAppDelegate *_appDelegate;
	
	NSArray *_cellAttributes;
	NSDictionary *_cellKeysForAttributes;
	
	NSArray *_content;
	
	NSString *_dumpedFilePath;
}

@property (nonatomic, readonly) ObjectiveDumpAppDelegate *appDelegate;
@property (nonatomic, readonly) Class cellClass;
@property (nonatomic, readonly) UITableViewCellStyle cellStyle;
@property (nonatomic, readonly) NSArray *cellAttributes;
@property (nonatomic, readonly) NSDictionary *cellKeysForAttributes;
@property (nonatomic, readonly) NSArray *content;
@property (nonatomic, copy) NSString *dumpedFilePath;

// Setting up 
- (void)setupTableView;
- (void)setupNavigationBar;
- (void)setupToolbar;

// Cell properties
- (Class)cellClass;
- (NSArray *)cellAttributes;
- (NSDictionary *)cellKeysForAttributes;

// Cell property helper
- (NSString *)keyForAttribute:(NSString *)attribute;

// Retrieve object linked to row
- (id)objectForIndexPath:(NSIndexPath *)indexPath;

// Restore levels
- (void)restoreLevelWithSelectionArray:(NSArray *)selectionArray;

@end
