//
//  BaseDataSource.m
//  
//
//  Created by Anthony Mittaz on 1/07/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import "BaseDataSource.h"
#import "ODDateAdditions.h"

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
	
	static NSString *MyCellIdentifier = @"MyCellIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyCellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyCellIdentifier] autorelease];
    }
	
	//id object = [self objectForIndexPath:indexPath];
    
	// Configure the cell.
	
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
	if (self.fetchedResultsController) {
		id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
		return [sectionInfo numberOfObjects];
	}
	
	// Check if content first elemetn return array or not
	// If yes, tableview has more than one section
	if (self.content && self.content.count > section
		&& [[self.content objectAtIndex:section]respondsToSelector:@selector(objectAtIndex:)]) {
		return [[self.content objectAtIndex:section]count];
	}
	return self.content.count;
}

- (id)objectForIndexPath:(NSIndexPath *)indexPath
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
		[self.delegate dataSourceDidStartLoading:self];
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
	if (self.canGoNextKey) {
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
	
	self.itemsCount = [[info valueForKey:@"totalItemsCount"]integerValue];
	
	[self savecanGoNextWhenCached:self.canGoNext];
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(dataSource:didFinishLoadingWithInfoDictionary:)]) {
		[self.delegate dataSource:self didFinishLoadingWithInfoDictionary:info];
	}
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc
{
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


//
//	FetchResultsController example
//
//- (NSFetchedResultsController *)fetchedResultsController {
//    
//    if (fetchedResultsController != nil) {
//        return fetchedResultsController;
//    }
//    
//    /*
//	 Set up the fetched results controller.
//	 */
//	// Create the fetch request for the entity.
//	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//	// Edit the entity name as appropriate.
//	NSEntityDescription *entity = [NSEntityDescription entityForName:@"GPProduct" inManagedObjectContext:self.managedObjectContext];
//	[fetchRequest setEntity:entity];
//	
//	// Edit the sort key as appropriate.
//	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"Event" ascending:YES];
//	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
//	
//	[fetchRequest setSortDescriptors:sortDescriptors];
//	
//	// Edit the section name key path and cache name if appropriate.
//    // nil for section name key path means "no sections".
//	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
//    aFetchedResultsController.delegate = self;
//	self.fetchedResultsController = aFetchedResultsController;
//	
//	[aFetchedResultsController release];
//	[fetchRequest release];
//	[sortDescriptor release];
//	[sortDescriptors release];
//	
//	return fetchedResultsController;
//}