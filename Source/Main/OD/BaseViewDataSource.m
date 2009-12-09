//
//  BaseViewDataSource.m
//  ObjectiveDump
//
//  Created by Anthony Mittaz on 9/12/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import "BaseViewDataSource.h"
#import "ODDateAdditions.h"
#import "ODNetworkManager.h"

@implementation BaseViewDataSource

@synthesize isLoading=_isLoading;
@synthesize lastLoadedTime=_lastLoadedTime;
@synthesize hasFailedLoading=_hasFailedLoading;
@synthesize delegate=_delegate;
@synthesize dataSource=_dataSource;
@synthesize operationQueue=_operationQueue;
@synthesize entityName=_entityName;
@synthesize operation=_operation;

#pragma mark -
#pragma mark Init

- (id)init
{
	self = [super init];
	if (self != nil) {
		self.isLoading = FALSE;
		self.hasFailedLoading = FALSE;
		self.lastLoadedTime = nil;
		self.delegate = nil;
		self.dataSource = nil;
		self.operationQueue = nil;
		self.entityName = nil;
	}
	return self;
}

- (id)initWithDelegate:(id)delegate 
			dataSource:(id)dataSource 
		operationQueue:(id)operationQueue
			entityName:(NSString *)entityName
{
	self = [super init];
	if (self != nil) {
		self.delegate = delegate;
		self.dataSource = dataSource;
		self.operationQueue = operationQueue;
		self.entityName = entityName;
		
		// Save the last loaded time 
		if (self.lastLoadedDefaultskey) {
			self.lastLoadedTime = [[NSUserDefaults standardUserDefaults]objectForKey:self.lastLoadedDefaultskey];
		}
	}
	return self;
}

#pragma mark -
#pragma mark Base Data Source Subclass Protocol

- (void)setupAndStartOperation
{
	// Nothing
}


#pragma mark -
#pragma mark Start Loading

- (void)startLoading
{
	// Update the last fetched date
	// Doing this in order to check
	// Ir url has changed since last fetch
	// Save the last loaded time 
	if (self.lastLoadedDefaultskey) {
		self.lastLoadedTime = [[NSUserDefaults standardUserDefaults]objectForKey:self.lastLoadedDefaultskey];
	}
	// Check expiry date for last loaded data
	// If still valid does not start
	if (self.dataSourceHasExpired && !self.isLoading) {
		if (self.delegate && [self.delegate respondsToSelector:@selector(dataSourceDidStartLoading:)]) {
			// Check for network connection
			// If not throw error
			if ([ODNetworkManager sharedODNetworkManager].hasValidNetworkConnection) {
				[self setupAndStartOperation];
				[self.delegate dataSourceDidStartLoading:self];
			} else {
				// Inform the user that network is down
				if (self.delegate && [self.delegate respondsToSelector:@selector(dataSourceNetworkIsDown:)]) {	
					[self.delegate dataSourceNetworkIsDown:self];
				}
			}
		}
	} else {
		// Data is still valid
		[self cancelLoading];
	}
}

- (void)startLoadingNoExpiry
{
	// Update the last fetched date
	// Doing this in order to check
	// Ir url has changed since last fetch
	// Save the last loaded time 
	if (self.lastLoadedDefaultskey) {
		self.lastLoadedTime = [[NSUserDefaults standardUserDefaults]objectForKey:self.lastLoadedDefaultskey];
	}
	// Check expiry date for last loaded data
	// If still valid does not start
	if (!self.isLoading) {
		if (self.delegate && [self.delegate respondsToSelector:@selector(dataSourceDidStartLoading:)]) {
			// Check for network connection
			// If not throw error
			if ([ODNetworkManager sharedODNetworkManager].hasValidNetworkConnection) {
				[self setupAndStartOperation];
				[self.delegate dataSourceDidStartLoading:self];
			} else {
				// Inform the user that network is down
				if (self.delegate && [self.delegate respondsToSelector:@selector(dataSourceNetworkIsDown:)]) {	
					[self.delegate dataSourceNetworkIsDown:self];
				}
			}
		}
	} else {
		// Data is still valid
		[self cancelLoading];
	}
}


#pragma mark -
#pragma mark Cancel Loading

- (void)cancelLoading
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(dataSourceDidCancelLoading:)]) {
		[self.delegate dataSourceDidCancelLoading:self];
	}
}

// Get the next url for default operation
- (NSURL *)nextURL
{
	NSURL *nextURL = nil;
	if (self.dataSource && [self.dataSource respondsToSelector:@selector(ddataSourceNextURL:)]) {
		nextURL = [self.dataSource dataSourceNextURL:self];
	}
	return nextURL;
}

#pragma mark -
#pragma mark Status

- (BOOL)isLoaded
{
	return (self.lastLoadedTime != nil && !self.hasFailedLoading);
}

// Save last fetch date to user prefs
- (void)saveLastFetchedDate:(NSDate *)date
{
	if (self.lastLoadedDefaultskey) {
		// Only if offset is not greater than 0
		[[NSUserDefaults standardUserDefaults]setObject:date forKey:self.lastLoadedDefaultskey];
	}
}

- (NSString *)lastLoadedDefaultskey
{
	if (self.dataSource && [self.dataSource respondsToSelector:@selector(dataSourceLastLoadedDefaultskey:)]) {
		return [self.delegate dataSourceLastLoadedDefaultskey:self];
	}
	return nil;
}

- (NSTimeInterval)expirtyTimeInterval
{
	if (self.dataSource && [self.dataSource respondsToSelector:@selector(dataSourceExpirtyTimeInterval:)]) {
		return [self.delegate dataSourceExpirtyTimeInterval:self];
	}
	return 0.0;
}

- (BOOL)dataSourceHasExpired
{
	if (self.dataSource && [self.dataSource respondsToSelector:@selector(dataSourceHasExpired:)]) {
		return [self.dataSource dataSourceHasExpired:self];
	}
	// Compute the expired date
	NSDate *expiredDate = [[NSDate date]addTimeInterval:self.expirtyTimeInterval];
	
	return [self.lastLoadedTime isLaterThanDate:expiredDate];
}

// Additional object
- (id)additionalObject
{
	if (self.dataSource && [self.dataSource respondsToSelector:@selector(dataSourceAdditionalObject:)]) {
		return [self.dataSource dataSourceAdditionalObject:self];
	}
	return nil;
}

#pragma mark -
#pragma mark Default Operation Delegate

- (void)defaultOperationDidStartLoadingWithInfo:(NSDictionary *)info
{
	// Show the netowrk activity indicator while operation is doing something
	[[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:TRUE];
	// Show that datasource is loading
	self.isLoading = TRUE;
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
	// Show that datasource is not loading
	self.isLoading = FALSE;
	
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
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(dataSource:didFinishLoadingWithInfoDictionary:)]) {
		[self.delegate dataSource:self didFinishLoadingWithInfoDictionary:info];
	}
	// Show that datasource is not loading
	self.isLoading = FALSE;
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc
{
	[_operation release];
	[_entityName release];
	[_operationQueue release];
	[_delegate release];
	[_dataSource release];
	[_lastLoadedTime release];
	
	[super dealloc];
}

@end
