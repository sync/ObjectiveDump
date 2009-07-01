//
//  BaseDataSource.h
//  
//
//  Created by Anthony Mittaz on 1/07/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DefaultOperation.h"

@protocol BaseDataSourceDelegate;

@interface BaseDataSource : NSObject <DefaultOperationDelegate>{
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
	
	NSOperationQueue *_operationQueue;
}

@property (nonatomic) BOOL isLoading;
@property (nonatomic, readonly) BOOL isLoaded;
@property (nonatomic, retain) NSDate *lastLoadedTime;
@property (nonatomic) BOOL hasFailedLoading;
@property (nonatomic) NSInteger itemsCount;
@property (nonatomic) NSInteger lastDisplayedItemIndex;
@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) NSOperationQueue *operationQueue;
@property (nonatomic, readonly) NSURL *nextURL;
@property (nonatomic, readonly) BOOL canGoNext;

// Using this method you can
// Easily fill a tableView
- (void)startLoading;
- (void)cancelLoading;
- (void)goNext;

@end

@protocol BaseDataSourceDelegate <NSObject>

@optional

// Useful when constructing url to fetch ws
- (NSURL *)dataSource:(BaseDataSource *)dataSource nextURLWithLastDisplayedItemIndex:(NSInteger)lastDisplayedItemIndex;
// Useful when for example having to refresh a tableview 
// Could include core data object id, or else if non core data related
// Inside infoDictionary
- (void)dataSource:(BaseDataSource *)dataSource didFinishLoadingWithInfoDictionary:(NSDictionary *)infoDictionary;
// Inform the delegate fetch events
- (void)dataSourceDidStartLoading:(BaseDataSource *)dataSource;
- (void)dataSourceDidCancelLoading:(BaseDataSource *)dataSource;
- (void)dataSource:(BaseDataSource *)dataSource didFailLoadingWithErrorString:(NSString *)errorString;

@end