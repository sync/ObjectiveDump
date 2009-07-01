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
		self.lastLoadedTime = nil;
		self.hasFailedLoading = FALSE;
		self.itemsCount = 0;
		self.lastDisplayedItemIndex = 0;
	}
	return self;
}


- (void)startLoading
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(dataSourceDidStartLoading:)]) {
		[self.delegate dataSourceDidStartLoading:self];
	}
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
	
	// Set that the last loading try has succeed
	self.hasFailedLoading = FALSE;
	
	// Increase the last diplayed index
	self.lastDisplayedItemIndex += [[info valueForKey:@"lastDisplayedItemIndex"]integerValue];
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(dataSource:didFinishLoadingWithInfoDictionary:)]) {
		[self.delegate dataSource:self didFinishLoadingWithInfoDictionary:info];
	}
}




- (void)dealloc
{
	[_operationQueue release];
	[_delegate release];
	[_lastLoadedTime release];
	
	[super dealloc];
}

@end
