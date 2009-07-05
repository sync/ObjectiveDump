//
//  BaseTableViewController.h
//  
//
//  Created by Anthony Mittaz on 5/02/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "BaseDataSource.h"

@protocol BaseTableViewControllerSubclass <NSObject>

@optional

@property (nonatomic, readonly) Class cellClass;
@property (nonatomic, readonly) UITableViewCellStyle cellStyle;
@property (nonatomic, readonly) NSMutableArray *content;

// Setting up 
- (void)setupDataSource;
- (void)setupCoreData;

// Cell properties
- (NSDictionary *)attributesForCell:(UITableViewCell *)cell withObject:(id)object;

@end


@interface BaseTableViewController : UITableViewController <UIAlertViewDelegate,BaseViewControllerSubclass,BaseTableViewControllerSubclass>{	
	NSMutableArray *_content;
	NSString *_dumpedFilePath;
	
	BaseDataSource *_dataSource;
}

@property (nonatomic, copy) NSString *dumpedFilePath;
@property (nonatomic, retain) BaseDataSource *dataSource;


// Retrieve object linked to row
- (id)objectForIndexPath:(NSIndexPath *)indexPath;

// Reload tableView when context save
- (void)contextDidSave:(NSNotification *)notification;

@end
