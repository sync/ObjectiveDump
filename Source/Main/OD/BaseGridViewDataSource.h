//
//  BaseGridViewDataSource.h
//  ObjectiveDump
//
//  Created by Anthony Mittaz on 3/12/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DefaultOperation.h"
#import <CoreData/CoreData.h>
#import "ODGridView.h"

@protocol BaseGridViewDataSourceSubclass <NSObject>

@required

// Here you can for example
// Setup a default operation
// Add it to the operation queue
- (void)setupAndStartOperation;

@optional

// Content
@property (nonatomic, readonly) NSMutableArray *content;

@end

@protocol BaseGridViewDataSource;
@protocol BaseGridViewDataSourceDelegate;

@interface BaseGridViewDataSource : NSObject <DefaultOperationDelegate, BaseGridViewDataSourceSubclass, ODGridViewDataSource>{
	
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
	id<BaseGridViewDataSourceDelegate> _delegate;
	
	id<BaseGridViewDataSource> _dataSource;
	
	NSOperationQueue *_operationQueue;
	
	// Table view cell setup
	NSInteger _rowHeight;
	
	// Content
	NSMutableArray *_content;
	// Save content when view did unload
	NSString *_dumpedFilePath;
	
	// Core Data
	NSString *_entityName;
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
@property (nonatomic, readonly) id additionalObject;
@property (nonatomic, readonly) BOOL canGoNextWhenCached;
@property (nonatomic, readonly) NSString *canGoNextKey;

- (id)initWithDelegate:(id)delegate 
			dataSource:(id)dataSource 
		operationQueue:(id)operationQueue
			entityName:(NSString *)entityName;

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

- (void)resetContent;

//#warning - (void)addObject:(id)object;
//#warning - (void)deleteObjectAtIndexPath:(NSIndexPath *)indexPath;

@end

@protocol BaseGridViewDataSource <NSObject>

@required

// Useful when constructing url to fetch ws
- (NSURL *)dataSource:(BaseGridViewDataSource *)dataSource nextURLWithLastDisplayedItemIndex:(NSInteger)lastDisplayedItemIndex;

@optional

// Save the last time the data source successfully load remote data
- (NSString *)dataSourceLastLoadedDefaultskey:(BaseGridViewDataSource *)dataSource;
// Set an expiry date for last data loaded
// If does not set anything data source will
// Always try to reload
// If data source has expired is implement in delegate this method is ignored
- (NSTimeInterval)dataSourceExpirtyTimeInterval:(BaseGridViewDataSource *)dataSource;
// Possiblity to tell the data source when data source is expired
- (BOOL)dataSourceHasExpired:(BaseGridViewDataSource *)dataSource;
// Possiblity to pass an addiontional object to the data source
- (id)dataSourceAdditionalObject:(BaseGridViewDataSource *)dataSource;
// Help determine if the data source can go next when data
// Was previously cached
- (NSString *)dataSourceCanGoNextDefaultskey:(BaseGridViewDataSource *)dataSource;


@end

@protocol BaseGridViewDataSourceDelegate <NSObject>

@optional

// Useful when for example having to refresh a tableview 
// Could include core data object id, or else if non core data related
// Inside infoDictionary
- (void)dataSource:(BaseGridViewDataSource *)dataSource didFinishLoadingWithInfoDictionary:(NSDictionary *)infoDictionary;
// Inform the delegate for fetch events
- (void)dataSourceDidStartLoading:(BaseGridViewDataSource *)dataSource;
- (void)dataSourceDidCancelLoading:(BaseGridViewDataSource *)dataSource;
- (void)dataSource:(BaseGridViewDataSource *)dataSource didFailLoadingWithErrorString:(NSString *)errorString;
- (void)dataSourceNetworkIsDown:(BaseGridViewDataSource *)dataSource;

@end
