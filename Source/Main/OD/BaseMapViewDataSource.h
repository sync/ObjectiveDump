//
//  BaseMapViewDataSource.h
//  ObjectiveDump
//
//  Created by Anthony Mittaz on 25/08/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DefaultOperation.h"
#import <CoreData/CoreData.h>

@protocol BaseMapViewDataSourceSubclass <NSObject>

@required

// Here you can for example
// Setup a default operation
// Add it to the operation queue
- (void)setupAndStartOperation;

@optional

// Content
@property (nonatomic, readonly) NSMutableArray *content;

@end

@protocol BaseMapViewDataSource;
@protocol BaseMapViewDataSourceDelegate;

@interface BaseMapViewDataSource : NSObject <DefaultOperationDelegate, BaseMapViewDataSourceSubclass>{
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
	id<BaseMapViewDataSourceDelegate> _delegate;
	
	id<BaseMapViewDataSource> _dataSource;
	
	NSOperationQueue *_operationQueue;
	
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
- (void)cancelLoading;
- (void)goNext;

// Save last fetch date to user prefs
- (void)saveLastFetchedDate:(NSDate *)date;

// Save wether it is possible or not to go next when chached
- (void)savecanGoNextWhenCached:(BOOL)goNext;

@end

@protocol BaseMapViewDataSource <NSObject>

@required

// Useful when constructing url to fetch ws
- (NSURL *)dataSource:(BaseMapViewDataSource *)dataSource nextURLWithLastDisplayedItemIndex:(NSInteger)lastDisplayedItemIndex;

@optional

// Save the last time the data source successfully load remote data
- (NSString *)dataSourceLastLoadedDefaultskey:(BaseMapViewDataSource *)dataSource;
// Set an expiry date for last data loaded
// If does not set anything data source will
// Always try to reload
// If data source has expired is implement in delegate this method is ignored
- (NSTimeInterval)dataSourceExpirtyTimeInterval:(BaseMapViewDataSource *)dataSource;
// Possiblity to tell the data source when data source is expired
- (BOOL)dataSourceHasExpired:(BaseMapViewDataSource *)dataSource;
// Possiblity to pass an addiontional object to the data source
- (id)dataSourceAdditionalObject:(BaseMapViewDataSource *)dataSource;
// Help determine if the data source can go next when data
// Was previously cached
- (NSString *)dataSourceCanGoNextDefaultskey:(BaseMapViewDataSource *)dataSource;


@end

@protocol BaseMapViewDataSourceDelegate <NSObject>

@optional

// Useful when for example having to refresh a tableview 
// Could include core data object id, or else if non core data related
// Inside infoDictionary
- (void)dataSource:(BaseMapViewDataSource *)dataSource didFinishLoadingWithInfoDictionary:(NSDictionary *)infoDictionary;
// Inform the delegate for fetch events
- (void)dataSourceDidStartLoading:(BaseMapViewDataSource *)dataSource;
- (void)dataSourceDidCancelLoading:(BaseMapViewDataSource *)dataSource;
- (void)dataSource:(BaseMapViewDataSource *)dataSource didFailLoadingWithErrorString:(NSString *)errorString;
- (void)dataSourceNetworkIsDown:(BaseMapViewDataSource *)dataSource;

@end
