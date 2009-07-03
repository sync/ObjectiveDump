//
//  BaseDataSource.m
//  
//
//  Created by Anthony Mittaz on 1/07/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import "BaseDataSource.h"


@implementation BaseDataSource

@synthesize isLoading=_isLoading;
@synthesize lastLoadedTime=_lastLoadedTime;
@synthesize hasFailedLoading=_hasFailedLoading;
@synthesize itemsCount=_itemsCount;
@synthesize lastDisplayedItemIndex=_lastDisplayedItemIndex;
@synthesize delegate=_delegate;
@synthesize operationQueue=_operationQueue;

- (id)init
{
	self = [super init];
	if (self != nil) {
		self.isLoading = FALSE;
		self.hasFailedLoading = FALSE;
		self.itemsCount = 0;
		self.lastDisplayedItemIndex = 0;
	}
	return self;
}

- (id)initWithDelegate:(id)delegate
{
	self = [super init];
	if (self != nil) {
		self.delegate = delegate;
		if (self.lastLoadedDefaultskey) {
			NSDate *lastLoadedTime = [NSDate dateWithTimeIntervalSince1970:[[[NSUserDefaults standardUserDefaults]valueForKey:self.lastLoadedDefaultskey]doubleValue]];
			self.lastLoadedTime = lastLoadedTime;
		}
	}
	return self;
}


- (void)startLoading
{
	// Check expiry date for last loaded data
	// If still valid does not start
	if (self.dataSourceHasExpired) {
		if (self.delegate && [self.delegate respondsToSelector:@selector(dataSourceDidStartLoading:)]) {
			[self setupAndStartOperation];
			[self.delegate dataSourceDidStartLoading:self];
		}
	} else {
		// Data is still valid
		[self cancelLoading];
	}
}

- (void)setupAndStartOperation
{
	// Nothing
}


- (void)cancelLoading
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(dataSourceDidCancelLoading:)]) {
		[self.delegate dataSourceDidCancelLoading:self];
	}
}

- (void)goNext
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(dataSource:nextURLWithLastDisplayedItemIndex:)]) {
		if (self.nextURL) {
			[self startLoading];
			[self.delegate dataSourceDidStartLoading:self];
		}
	}
}

// Get the next url for default operation
- (NSURL *)nextURL
{
	NSURL *nextURL = [self.delegate dataSource:self nextURLWithLastDisplayedItemIndex:self.lastDisplayedItemIndex];
	return nextURL;
}

- (BOOL)canGoNext
{
	return (self.lastDisplayedItemIndex < self.itemsCount);
}

- (BOOL)isLoaded
{
	return (self.lastLoadedTime != nil && !self.hasFailedLoading);
}

// Save last fetch date to user prefs
- (void)saveLastFetchedDate:(NSDate *)date
{
	if (self.lastLoadedDefaultskey) {
		[[NSUserDefaults standardUserDefaults]setDouble:[date timeIntervalSince1970] forKey:self.lastLoadedDefaultskey];
	}
}

#pragma mark -
#pragma mark Default Operation Delegate

- (void)defaultOperationDidStartLoadingWithInfo:(NSDictionary *)info
{
	// Show the netowrk activity indicator while operation is doing something
	[[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:TRUE];
}

- (void)defaultOperationDidFailWithInfo:(NSDictionary *)info
{
	// Remove network activity if operation fail
	[[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:FALSE];
	
	// Set the last time data source failed to download a file
	self.lastLoadedTime = [NSDate date];
	
	// Set that the last loading try has failed
	self.hasFailedLoading = TRUE;
	
	// Transmit the error to the data source delegate
	NSString *errorString = [info valueForKey:@"errorString"];
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(dataSource:didFailLoadingWithErrorString:)]) {
		[self.delegate dataSource:self didFailLoadingWithErrorString:errorString];
	}
	
}

- (void)defaultOperationDidFinishLoadingWithInfo:(NSDictionary *)info
{
	// Remove network activity if operation is done
	[[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:FALSE];
	
	// Set the last time data source succeed to download a file
	self.lastLoadedTime = [NSDate date];
	
	// Save to the user defaults, useful for
	// Set the last fetched time to user defaults
	[self saveLastFetchedDate:self.lastLoadedTime];
	
	// Set that the last loading try has succeed
	self.hasFailedLoading = FALSE;
	
	// Increase the last diplayed index
	self.lastDisplayedItemIndex += [[info valueForKey:@"lastDisplayedItemIndex"]integerValue];
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(dataSource:didFinishLoadingWithInfoDictionary:)]) {
		[self.delegate dataSource:self didFinishLoadingWithInfoDictionary:info];
	}
}

- (NSString *)lastLoadedDefaultskey
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(dataSourceLastLoadedDefaultskey:)]) {
		return [self.delegate dataSourceLastLoadedDefaultskey:self];
	}
	return nil;
}

- (NSTimeInterval)expirtyTimeInterval
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(dataSourceExpirtyTimeInterval:)]) {
		return [self.delegate dataSourceExpirtyTimeInterval:self];
	}
	return 0.0;
}

- (BOOL)dataSourceHasExpired
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(dataSourceHasExpired:)]) {
		return [self.delegate dataSourceHasExpired:self];
	}
	NSDate *now = [NSDate date];
	NSDate *expiredDate = [[NSDate date]addTimeInterval:self.expirtyTimeInterval];
	NSTimeInterval difference = [now timeIntervalSinceDate:expiredDate];
	return (difference >= 0);
}

- (void)dealloc
{
	[_operationQueue release];
	[_delegate release];
	[_lastLoadedTime release];
	
	[super dealloc];
}

@end