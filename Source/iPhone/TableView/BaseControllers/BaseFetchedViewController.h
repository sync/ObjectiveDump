//
//  BaseFetchedViewController.h
//  
//
//  Created by Anthony Mittaz on 14/04/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface BaseFetchedViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>{
	NSFetchedResultsController *fetchedResultsController;
	
	UITableView *_tableView;
	
	NSString *_entityName;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, readonly) Class cellClass;
@property (nonatomic, readonly) UITableViewCellStyle cellStyle;

@property (nonatomic, readonly) NSString *entityName;

// Cell properties
- (Class)cellClass;
- (NSDictionary *)attributesForCell:(UITableViewCell *)cell withObject:(id)object;

// Retrieve object linked to row
- (id)objectForIndexPath:(NSIndexPath *)indexPath;

// Merge any saved changes with the context on other thread
- (void)contextDidSave:(NSNotification *)notification;


@end
