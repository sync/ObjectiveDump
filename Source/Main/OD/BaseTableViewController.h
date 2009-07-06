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

// Non persistent content
@property (nonatomic, readonly) NSMutableArray *content;

// Persistent content
@property (nonatomic, readonly) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, readonly) NSString *entityName;

// Get the context
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

// Setting up 
- (void)setupDataSource;
- (void)setupCoreData;

@end


@interface BaseTableViewController : UITableViewController <UIAlertViewDelegate, BaseViewControllerSubclass, BaseTableViewControllerSubclass>{	
	// Non persitent content
	NSMutableArray *_content;
	NSString *_dumpedFilePath;
	
	// Persitent content
	NSFetchedResultsController *_fetchedResultsController;
	NSString *_entityName;
	
	// Get the context
	NSManagedObjectContext *_managedObjectContext;
	
	BaseDataSource *_dataSource;
	
	id _object;
}

@property (nonatomic, copy) NSString *dumpedFilePath;
@property (nonatomic, retain) BaseDataSource *dataSource;
@property (nonatomic, retain) id object;


// Retrieve object linked to row
- (id)objectForIndexPath:(NSIndexPath *)indexPath;

// TableView Helper
- (NSInteger)numberOfSectionsForTableView:(UITableView *)tableView;
- (NSInteger)numberOfRowsInSection:(NSInteger)section forTableView:(UITableView *)tableView;

// Reload tableView when context save
- (void)contextDidSave:(NSNotification *)notification;

@end
