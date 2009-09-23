//
//  BaseDataSource.h
//  
//
//  Created by Anthony Mittaz on 1/07/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DefaultOperation.h"
#import <CoreData/CoreData.h>

@protocol BaseDataSourceSubclass <NSObject>

@required

// Here you can for example
// Setup a default operation
// Add it to the operation queue
- (void)setupAndStartOperation;

@optional

// Content
@property (nonatomic, readonly) NSMutableArray *content;

@end

@protocol BaseDataSource;
@protocol BaseDataSourceDelegate;

@interface BaseDataSource : NSObject <DefaultOperationDelegate, BaseDataSourceSubclass, UITableViewDataSource>{
	// Check if data source is still fetching
	// Remote data
	BOOL _isLoading;
	
	// Return when was the last
	// Time the data source
	// Tried to fetch the 
	// Remote data
	NSDate *_lastLoadedTime;
	
	// Unable to fetch remote data
	BOOL _hasFailedLoading;
	
	NSInteger _itemsCount;
	NSInteger _lastDisplayedItemIndex;
	
	// Base Data Source delegate
	// In charge of helping finding
	// Remote data
	id<BaseDataSourceDelegate> _delegate;
	
	id<BaseDataSource> _dataSource;
	
	NSOperationQueue *_operationQueue;
	
	// Table view cell setup
	NSInteger _rowHeight;
	
	// Content
	NSMutableArray *_content;
	// Save content when view did unload
	NSString *_dumpedFilePath;
	
	// Core Data
	NSString *_entityName;
	NSFetchedResultsController *_fetchedResultsController;
}

@property (nonatomic) BOOL isLoading;
@property (nonatomic, readonly) BOOL isLoaded;
@property (nonatomic, retain) NSDate *lastLoadedTime;
@property (nonatomic) BOOL hasFailedLoading;
@property (nonatomic) NSInteger itemsCount;
@property (nonatomic) NSInteger lastDisplayedItemIndex;
@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) id dataSource;
@property (nonatomic, retain) NSOperationQueue *operationQueue;
@property (nonatomic, readonly) NSURL *nextURL;
@property (nonatomic, readonly) BOOL canGoNext;
@property (nonatomic, readonly) NSString *lastLoadedDefaultskey;
@property (nonatomic, readonly) BOOL dataSourceHasExpired;
@property (nonatomic) NSInteger rowHeight;
@property (nonatomic, copy) NSString *dumpedFilePath;
@property (nonatomic, copy) NSString *entityName;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, readonly) id additionalObject;
@property (nonatomic, readonly) BOOL canGoNextWhenCached;
@property (nonatomic, readonly) NSString *canGoNextKey;

- (id)initWithDelegate:(id)delegate 
			dataSource:(id)dataSource 
		operationQueue:(id)operationQueue
			entityName:(NSString *)entityName
fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController;

// Using this method you can
// Easily fill a tableView
- (void)startLoading;
- (void)startLoadingNoExpiry;
- (void)cancelLoading;
- (void)goNext;

// Save last fetch date to user prefs
- (void)saveLastFetchedDate:(NSDate *)date;

// Save wether it is possible or not to go next when chached
- (void)savecanGoNextWhenCached:(BOOL)goNext;

// Retrieve object linked to row
// Retrieve object linked to row
- (id)objectForIndexPath:(NSIndexPath *)indexPath forTableView:(UITableView *)tableView;

// TableView methods
- (NSInteger)numberOfSectionsForTableView:(UITableView *)tableView;
- (NSInteger)numberOfRowsInSection:(NSInteger)section forTableView:(UITableView *)tableView;

// Find out when given indexPath corresponds to the last row
- (BOOL)isIndexPathLastRow:(NSIndexPath *)indexPath forTableView:(UITableView *)tableView;

//#warning - (void)addObject:(id)object;
//#warning - (void)deleteObjectAtIndexPath:(NSIndexPath *)indexPath;

@end

@protocol BaseDataSource <NSObject>

@required

// Useful when constructing url to fetch ws
- (NSURL *)dataSource:(BaseDataSource *)dataSource nextURLWithLastDisplayedItemIndex:(NSInteger)lastDisplayedItemIndex;

@optional

// Save the last time the data source successfully load remote data
- (NSString *)dataSourceLastLoadedDefaultskey:(BaseDataSource *)dataSource;
// Set an expiry date for last data loaded
// If does not set anything data source will
// Always try to reload
// If data source has expired is implement in delegate this method is ignored
- (NSTimeInterval)dataSourceExpirtyTimeInterval:(BaseDataSource *)dataSource;
// Possiblity to tell the data source when data source is expired
- (BOOL)dataSourceHasExpired:(BaseDataSource *)dataSource;
// Possiblity to pass an addiontional object to the data source
- (id)dataSourceAdditionalObject:(BaseDataSource *)dataSource;
// Help determine if the data source can go next when data
// Was previously cached
- (NSString *)dataSourceCanGoNextDefaultskey:(BaseDataSource *)dataSource;


@end

@protocol BaseDataSourceDelegate <NSObject>

@optional

// Useful when for example having to refresh a tableview 
// Could include core data object id, or else if non core data related
// Inside infoDictionary
- (void)dataSource:(BaseDataSource *)dataSource didFinishLoadingWithInfoDictionary:(NSDictionary *)infoDictionary;
// Inform the delegate for fetch events
- (void)dataSourceDidStartLoading:(BaseDataSource *)dataSource;
- (void)dataSourceDidCancelLoading:(BaseDataSource *)dataSource;
- (void)dataSource:(BaseDataSource *)dataSource didFailLoadingWithErrorString:(NSString *)errorString;
- (void)dataSourceNetworkIsDown:(BaseDataSource *)dataSource;

@end