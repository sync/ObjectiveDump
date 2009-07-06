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
@synthesize dataSource=_dataSource;
@synthesize operationQueue=_operationQueue;
@synthesize cellClass=_cellClass;
@synthesize cellStyle=_cellStyle;
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
		self.cellClass = [UITableViewCell class];
		self.cellStyle = UITableViewCellStyleDefault;
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
			 cellClass:(Class)cellClass 
			 cellStyle:(UITableViewCellStyle)cellStyle
		operationQueue:(id)operationQueue
			fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
{
	self = [super init];
	if (self != nil) {
		self.delegate = delegate;
		self.dataSource = dataSource;
		self.cellClass = cellClass;
		self.cellStyle = cellStyle;
		self.operationQueue = operationQueue;
		
		// When nil core data is not used
		self.fetchedResultsController = fetchedResultsController;
		
		// Save the last loaded time 
		if (self.lastLoadedDefaultskey) {
			NSDate *lastLoadedTime = [NSDate dateWithTimeIntervalSince1970:[[[NSUserDefaults standardUserDefaults]valueForKey:self.lastLoadedDefaultskey]doubleValue]];
			self.lastLoadedTime = lastLoadedTime;
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

- (NSDictionary *)attributesForCell:(UITableViewCell *)cell withObject:(id)object
{
	// Empty dict
	return [NSDictionary dictionary];
}

#pragma mark -
#pragma mark Content

- (NSArray *)content
{
	if (!_content) {
		if ([[NSFileManager defaultManager]fileExistsAtPath:self.dumpedFilePath]) {
			_content = [NSMutableArray arrayWithContentsOfFile:self.dumpedFilePath];
			[[NSFileManager defaultManager]removeItemAtPath:self.dumpedFilePath error:nil];
			self.dumpedFilePath = nil;
		} else {
			_content = [[NSMutableArray alloc]init];
		}
	}
	return _content;
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	
	if (self.fetchedResultsController) {
		NSInteger sectionNumber = [[self.fetchedResultsController sections] count];
		return (sectionNumber>0)?sectionNumber:1;
	}
	
	// Check if content first elemetn return array or not
	// If yes, tableview has more than one section
	if (self.content && self.content.count > 0
		&& [[self.content objectAtIndex:0]respondsToSelector:@selector(objectAtIndex:)]) {
		return self.content.count;
	}
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
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


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(self.cellClass)];
    if (cell == nil) {
        cell = [[[self.cellClass alloc] initWithStyle:self.cellStyle reuseIdentifier:NSStringFromClass(self.cellClass)] autorelease];
    }
	
	id object = [self objectForIndexPath:indexPath];
    
	// Configure the cell.
	NSDictionary *cellAttributes = [self attributesForCell:cell withObject:object];
	
	for (NSString *keypath in cellAttributes) {
		[cell setValue:[cellAttributes valueForKey:keypath] forKeyPath:keypath];
	}
	
    return cell;
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
	return (self.content.count>indexPath.row)?[self.content objectAtIndex:indexPath.row]:nil; 
}


#pragma mark -
#pragma mark Start Loading

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
	return (self.lastDisplayedItemIndex < self.itemsCount);
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
		[[NSUserDefaults standardUserDefaults]setDouble:[date timeIntervalSince1970] forKey:self.lastLoadedDefaultskey];
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
	NSDate *now = [NSDate date];
	NSDate *expiredDate = [[NSDate date]addTimeInterval:self.expirtyTimeInterval];
	NSTimeInterval difference = [now timeIntervalSinceDate:expiredDate];
	return (difference >= 0);
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