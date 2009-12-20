//
//  BaseDataSource.m
//  
//
//  Created by Anthony Mittaz on 1/07/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import "BaseDataSource.h"
#import "ODDateAdditions.h"
#import "ODNetworkManager.h"

#define CanGoNextKeyHelper @"_cgnHelper"
#define CanGoNextKeyItemsCount @"CanGoNextKeyItemsCount"
#define CanGoNextKeyLastDisplayedItemIndex @"CanGoNextKeyLastDisplayedItemIndex"

@implementation BaseDataSource

@synthesize isLoading=_isLoading;
@synthesize lastLoadedTime=_lastLoadedTime;
@synthesize hasFailedLoading=_hasFailedLoading;
@synthesize itemsCount=_itemsCount;
@synthesize lastDisplayedItemIndex=_lastDisplayedItemIndex;
@synthesize delegate=_delegate;
@synthesize dataSource=_dataSource;
@synthesize operationQueue=_operationQueue;
@synthesize rowHeight=_rowHeight;
@synthesize dumpedFilePath=_dumpedFilePath;
@synthesize entityName=_entityName;
@synthesize fetchedResultsController=_fetchedResultsController;
@synthesize operation=_operation;

#pragma mark -
#pragma mark Init

- (id)init
{
	self = [super init];
	if (self != nil) {
		self.isLoading = FALSE;
		self.hasFailedLoading = FALSE;
		self.itemsCount = 0;
		self.lastDisplayedItemIndex = 0;
		self.lastLoadedTime = nil;
		self.delegate = nil;
		self.dataSource = nil;
		self.operationQueue = nil;
		// if set to -1 do nothing
		self.rowHeight = -1;
		self.entityName = nil;
		// When nil, core data is not used
		self.fetchedResultsController = nil;
	}
	return self;
}

- (id)initWithDelegate:(id)delegate 
			dataSource:(id)dataSource 
		operationQueue:(id)operationQueue
			entityName:(NSString *)entityName
			fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
{
	self = [super init];
	if (self != nil) {
		self.delegate = delegate;
		self.dataSource = dataSource;
		self.operationQueue = operationQueue;
		self.entityName = entityName;
		
		// When nil core data is not used
		self.fetchedResultsController = fetchedResultsController;
		
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
#pragma mark Content

- (NSMutableArray *)content
{
	if (!_content) {
		if ([[NSFileManager defaultManager]fileExistsAtPath:self.dumpedFilePath]) {
			_content = [NSMutableArray arrayWithContentsOfFile:self.dumpedFilePath];
			[[NSFileManager defaultManager]removeItemAtPath:self.dumpedFilePath error:nil];
			self.dumpedFilePath = nil;
		} else {
			_content = [[NSMutableArray alloc]initWithCapacity:0];
		}
	}
	return _content;
}

#pragma mark -
#pragma mark Reset Content

- (void)resetContent
{
	// refresh content
	[_content release];
	_content = nil;
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return [self numberOfSectionsForTableView:tableView];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	return [self numberOfRowsInSection:section forTableView:tableView];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	

#define MyCellIdentifier @"MyCellIdentifier"
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyCellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyCellIdentifier] autorelease];
    }
	
	//id object = [self objectForIndexPath:indexPath];
    
	// Configure the cell.
	if (self.delegateCanDownloadImage && !self.isContainerViewMoving) {
		// Tell delegate to start download image
		[self.delegate imageDownloaderShouldLoadImageAtUrl:nil 
												  forIndex:[NSNumber numberWithInteger:indexPath.row] 
												dataSource:self];
	}
	
    return cell;
}

#pragma mark -
#pragma mark Table view methods helper

- (NSInteger)numberOfSectionsForTableView:(UITableView *)tableView
{
	if (self.fetchedResultsController) {
		NSInteger sectionNumber = [[self.fetchedResultsController sections] count];
		return sectionNumber;
	}
	
	// Check if content first elemetn return array or not
	// If yes, tableview has more than one section
	if (self.content && self.content.count > 0
		&& [[self.content objectAtIndex:0]respondsToSelector:@selector(objectAtIndex:)]) {
		return self.content.count;
	}
	return 1;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section forTableView:(UITableView *)tableView
{
	NSInteger moreRowToAdd = 0;
	if ((self.canGoNext || self.canGoNextWhenCached) && self.canShowMore) {
		moreRowToAdd = 1;
	}
	
	if (self.fetchedResultsController) {
		id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
		return [sectionInfo numberOfObjects] + moreRowToAdd;
	}
	
	// Check if content first elemetn return array or not
	// If yes, tableview has more than one section
	if (self.content && self.content.count > section
		&& [[self.content objectAtIndex:section]respondsToSelector:@selector(objectAtIndex:)]) {
		return [[self.content objectAtIndex:section]count];
	}
	return self.content.count + moreRowToAdd;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section { 
    if (self.fetchedResultsController) {
		id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
		return [sectionInfo name];
	}
	return nil;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	if (self.fetchedResultsController) {
		return [self.fetchedResultsController sectionIndexTitles];
	}
	return nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if (self.fetchedResultsController) {
		return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
	}
	return 0;
}

- (id)objectForIndexPath:(NSIndexPath *)indexPath forTableView:(UITableView *)tableView;
{
	
	if (self.fetchedResultsController) {
		return [self.fetchedResultsController objectAtIndexPath:indexPath];
	}
	
	// Hack to see if array has got multiple sections or not
	NSArray *firstLevel = nil;
	if (self.content && self.content.count > indexPath.section
		&& [[self.content objectAtIndex:indexPath.section]respondsToSelector:@selector(objectAtIndex:)] 
		&& self.content.count>indexPath.section) {
		firstLevel = [self.content objectAtIndex:indexPath.section];
	} else {
		firstLevel = self.content;
	}
	// if nothing return nil
	return (firstLevel.count>indexPath.row)?[firstLevel objectAtIndex:indexPath.row]:nil; 
}

- (BOOL)isIndexPathLastRow:(NSIndexPath *)indexPath forTableView:(UITableView *)tableView
{
	BOOL isLast = FALSE;
	NSInteger totalNumberOfRows = [tableView numberOfRowsInSection:indexPath.section];
	if (totalNumberOfRows - 1 == indexPath.row) {
		isLast = TRUE;
	}
	return isLast;
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
			// Reset load more
			self.lastDisplayedItemIndex = 0;
			self.itemsCount = 0;
			
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

#pragma mark -
#pragma mark Go Next

- (void)goNext
{
	if (self.nextURL) {
		[self startLoading];
	}
}

// Get the next url for default operation
- (NSURL *)nextURL
{
	NSURL *nextURL = nil;
	if (self.dataSource && [self.dataSource respondsToSelector:@selector(dataSource:nextURLWithLastDisplayedItemIndex:)]) {
		nextURL = [self.dataSource dataSource:self nextURLWithLastDisplayedItemIndex:self.lastDisplayedItemIndex];
	}
	return nextURL;
}

- (BOOL)canGoNext
{
	BOOL canGoNext = (self.lastDisplayedItemIndex < self.itemsCount);
	if (canGoNext) {
		DLog(@"canGoNext");
	}
	return canGoNext;
}

- (NSString *)canGoNextKey
{
	NSString *canGoNextKey = nil;
	if (self.dataSource && [self.dataSource respondsToSelector:@selector(dataSourceCanGoNextDefaultskey:)]) {
		NSString *key = [self.dataSource dataSourceCanGoNextDefaultskey:self];
		if (key) {
			canGoNextKey = [NSString stringWithFormat:@"%@%@", key, CanGoNextKeyHelper];
		}
	}
	return canGoNextKey;
}

- (BOOL)canGoNextWhenCached
{
	BOOL canGoNextWhenCached = FALSE;
	// Make sure the data has not expired
	if (![self dataSourceHasExpired] && self.canGoNextKey) {
		canGoNextWhenCached = [[NSUserDefaults standardUserDefaults]boolForKey:self.canGoNextKey];
		// Set the total number of items
		self.itemsCount = [[NSUserDefaults standardUserDefaults]integerForKey:[NSString stringWithFormat:@"%@%@", 
														  self.canGoNextKey, 
														  CanGoNextKeyItemsCount]];
		// Set the offset
		self.lastDisplayedItemIndex = [[NSUserDefaults standardUserDefaults]integerForKey:[NSString stringWithFormat:@"%@%@", 
															 self.canGoNextKey, 
															 CanGoNextKeyLastDisplayedItemIndex]];
		
	}
	return canGoNextWhenCached;
}

// Save wether it is possible or not to go next when chached
- (void)savecanGoNextWhenCached:(BOOL)goNext
{
	if (self.canGoNextKey) {
		// Remember if it is possible to go next
		[[NSUserDefaults standardUserDefaults]setBool:goNext forKey:self.canGoNextKey];
		// Remember the total number of item
		[[NSUserDefaults standardUserDefaults]setInteger:self.itemsCount 
												  forKey:[NSString stringWithFormat:@"%@%@", 
														  self.canGoNextKey, 
														  CanGoNextKeyItemsCount]];
		// Remember the offset
		[[NSUserDefaults standardUserDefaults]setInteger:self.lastDisplayedItemIndex 
												  forKey:[NSString stringWithFormat:@"%@%@", 
														  self.canGoNextKey, 
														  CanGoNextKeyLastDisplayedItemIndex]];
	}
}

- (BOOL)canShowMore
{
	return (self.dataSource 
			&& [self.dataSource respondsToSelector:@selector(dataSourceShowMoreCell:forTableView:)]);
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
		if (self.lastDisplayedItemIndex == 0) {
			[[NSUserDefaults standardUserDefaults]setObject:date forKey:self.lastLoadedDefaultskey];
		}
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
	
	// Increase the last diplayed index
	self.lastDisplayedItemIndex += [[info valueForKey:@"lastDisplayedItemIndex"]integerValue];
	
	self.itemsCount = [[info valueForKey:@"totalItemsCount"]integerValue];
	
	[self savecanGoNextWhenCached:self.canGoNext];
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(dataSource:didFinishLoadingWithInfoDictionary:)]) {
		[self.delegate dataSource:self didFinishLoadingWithInfoDictionary:info];
	}
	// Show that datasource is not loading
	self.isLoading = FALSE;
}

// called by our ImageDownloader when an icon is ready to be displayed
- (void)imageDownloaderDidLoadImage:(UIImage *)image forIndex:(NSNumber *)index;
{
	if (self.delegateCanDownloadImage) {
		[self.delegate imageDownloaderDidLoadImage:image 
										  forIndex:index 
										dataSource:self];
	}
	// Refresh the item
	// Save the image
}

- (BOOL)isContainerViewMoving
{
	BOOL isContainerViewMoving = TRUE;
	if (self.delegate && [self.delegate respondsToSelector:@selector(isContainerViewMoving:)]) {
		isContainerViewMoving = [self.delegate isContainerViewMoving:self];
	}
	return isContainerViewMoving;
}

- (BOOL)delegateCanDownloadImage
{
	BOOL delegateCanDownloadImage = FALSE;
	
	if (self.delegate 
		&& [self.delegate respondsToSelector:@selector(imageDownloaderShouldLoadImageAtUrl:forIndex:dataSource:)] 
		&& [self.delegate respondsToSelector:@selector(imageDownloaderDidLoadImage:forIndex:dataSource:)]) {
		delegateCanDownloadImage = TRUE;
	}
	
	return delegateCanDownloadImage;
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc
{
	[_operation release];
	[_fetchedResultsController release];
	[_entityName release];
	[_dumpedFilePath release];
	[_content release];
	[_operationQueue release];
	[_delegate release];
	[_dataSource release];
	[_lastLoadedTime release];
	
	[super dealloc];
}

@end