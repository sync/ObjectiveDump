//
//  BaseTableViewController.h
//  
//
//  Created by Anthony Mittaz on 5/02/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import <CoreData/CoreData.h>
#import "BaseDataSource.h"

@protocol BaseTableViewControllerSubclass <NSObject>

@optional

// Non persistent content
@property (nonatomic, readonly) NSMutableArray *content;

// Persistent content
@property (nonatomic, readonly) NSFetchedResultsController *fetchedResultsController;

@end


@interface BaseTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, BaseViewControllerSubclass, BaseTableViewControllerSubclass, NSFetchedResultsControllerDelegate>{	
	// TableView
	UITableView *_tableView;
	
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
	BOOL _viewDidLoadCalled;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, copy) NSString *dumpedFilePath;
@property (nonatomic, retain) BaseDataSource *dataSource;
@property (nonatomic, retain) id object;
@property (nonatomic) BOOL viewDidLoadCalled;

// Loading View
- (void)showLoadingViewForText:(NSString *)loadingText;
- (void)hideLoadingView;

// Error View
- (void)showErrorViewForText:(NSString *)errorText;
- (void)hideErrorView;

// Retrieve object linked to row
- (id)objectForIndexPath:(NSIndexPath *)indexPath forTableView:(UITableView *)tableView;

// TableView Helper
- (NSInteger)numberOfSectionsForTableView:(UITableView *)tableView;
- (NSInteger)numberOfRowsInSection:(NSInteger)section forTableView:(UITableView *)tableView;

// Build Next Url
- (NSURL *)buildNextUrlWithOffset:(NSInteger)offset limit:(NSInteger)limit urlString:(NSString *)urlString;

// Core Data
- (BOOL)saveContextAndHandleErrors;

@end
