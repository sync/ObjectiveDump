//
//  BaseViewDataSource.h
//  ObjectiveDump
//
//  Created by Anthony Mittaz on 9/12/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DefaultOperation.h"
#import <CoreData/CoreData.h>

@protocol BaseViewDataSourceSubclass <NSObject>

@required

// Here you can for example
// Setup a default operation
// Add it to the operation queue
- (void)setupAndStartOperation;

@optional

@end

@protocol BaseViewDataSource;
@protocol BaseViewDataSourceDelegate;

@interface BaseViewDataSource : NSObject <DefaultOperationDelegate, BaseViewDataSourceSubclass>{
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
	
	// Base Data Source delegate
	// In charge of helping finding
	// Remote data
	id<BaseViewDataSourceDelegate> _delegate;
	
	id<BaseViewDataSource> _dataSource;
	
	NSOperationQueue *_operationQueue;
	
	// Core Data
	NSString *_entityName;
	
	DefaultOperation *_operation;
}

@property (nonatomic) BOOL isLoading;
@property (nonatomic, readonly) BOOL isLoaded;
@property (nonatomic, retain) NSDate *lastLoadedTime;
@property (nonatomic) BOOL hasFailedLoading;
@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) id dataSource;
@property (nonatomic, retain) NSOperationQueue *operationQueue;
@property (nonatomic, readonly) NSURL *nextURL;
@property (nonatomic, readonly) NSString *lastLoadedDefaultskey;
@property (nonatomic, readonly) BOOL dataSourceHasExpired;
@property (nonatomic, copy) NSString *entityName;
@property (nonatomic, readonly) id additionalObject;
@property (nonatomic, retain) DefaultOperation *operation;

- (id)initWithDelegate:(id)delegate 
			dataSource:(id)dataSource 
		operationQueue:(id)operationQueue
			entityName:(NSString *)entityName;

// Using this method you can
// Easily fill a tableView
- (void)startLoading;
- (void)startLoadingNoExpiry;
- (void)cancelLoading;

// Save last fetch date to user prefs
- (void)saveLastFetchedDate:(NSDate *)date;

@end

@protocol BaseViewDataSource <NSObject>

@required

// Useful when constructing url to fetch ws
- (NSURL *)dataSourceNextURL:(BaseViewDataSource *)dataSource;

@optional

// Save the last time the data source successfully load remote data
- (NSString *)dataSourceLastLoadedDefaultskey:(BaseViewDataSource *)dataSource;
// Set an expiry date for last data loaded
// If does not set anything data source will
// Always try to reload
// If data source has expired is implement in delegate this method is ignored
- (NSTimeInterval)dataSourceExpirtyTimeInterval:(BaseViewDataSource *)dataSource;
// Possiblity to tell the data source when data source is expired
- (BOOL)dataSourceHasExpired:(BaseViewDataSource *)dataSource;
// Possiblity to pass an addiontional object to the data source
- (id)dataSourceAdditionalObject:(BaseViewDataSource *)dataSource;

@end

@protocol BaseViewDataSourceDelegate <NSObject>

@optional

// Useful when for example having to refresh a tableview 
// Could include core data object id, or else if non core data related
// Inside infoDictionary
- (void)dataSource:(BaseViewDataSource *)dataSource didFinishLoadingWithInfoDictionary:(NSDictionary *)infoDictionary;
// Inform the delegate for fetch events
- (void)dataSourceDidStartLoading:(BaseViewDataSource *)dataSource;
- (void)dataSourceDidCancelLoading:(BaseViewDataSource *)dataSource;
- (void)dataSource:(BaseViewDataSource *)dataSource didFailLoadingWithErrorString:(NSString *)errorString;
- (void)dataSourceNetworkIsDown:(BaseViewDataSource *)dataSource;

@end
