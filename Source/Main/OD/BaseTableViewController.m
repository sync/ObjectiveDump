//
//  BaseTableViewController.m
//  
//
//  Created by Anthony Mittaz on 5/02/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import "BaseTableViewController.h"
#import "GloballyUniquePathStringAdditions.h"
#import "ODLoadingView.h"

#define LoadingViewTag 1034343
#define ErrorViewTag 1034354

@implementation BaseTableViewController

@synthesize tableView=_tableView;
@synthesize dumpedFilePath=_dumpedFilePath;
@synthesize dataSource=_dataSource;
@synthesize managedObjectContext=_managedObjectContext;
@synthesize object=_object;
@synthesize viewDidLoadCalled=_viewDidLoadCalled;

#pragma mark -
#pragma mark Initialisation

// The designated initializer. Override to perform setup that is required before the view is loaded.
// Only when xibless (interface buildder)
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Custom initialization
		[self setupCustomInitialisation];
	}
	return self;
}

// The designated initializer. Override to perform setup that is required before the view is loaded.
// Only when using xib (interface buildder)
- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super initWithCoder:decoder]) {
		// Custom initialization
		[self setupCustomInitialisation];
	}
	return self;
}

- (void)setupCustomInitialisation
{
	// Nothing
	self.viewDidLoadCalled = FALSE;
}

- (NSOperationQueue *)imageDownloadQueue
{
	if (!_imageDownloadQueue) {
		_imageDownloadQueue = [[NSOperationQueue alloc]init];
	}
	
	return _imageDownloadQueue;
}

- (NSMutableDictionary *)imageDownloaders
{
	if (!_imageDownloaders) {
		_imageDownloaders = [[NSMutableDictionary alloc]initWithCapacity:0];
	}
	
	return _imageDownloaders;
}

#pragma mark -
#pragma mark View Events

- (void)viewDidLoad 
{
	[super viewDidLoad];
	
	// Set for example
	// Color and items
	[self setupNavigationBar];
	
	// Set for example
	// Color and items 
	[self setupToolbar];
	
	// If using data source
	[self setupDataSource];
	
	// If using core data
	[self setupCoreData];
	
	// Set for example
	// Background color
	[self setupTableView];
	
	self.viewDidLoadCalled = TRUE;
}

- (void)viewDidUnload 
{	
	// Dump array content to temporary file
	// Only if non nil and non empty
	if (self.content && [self.content count]>0) {
		self.dumpedFilePath = [NSString globallyUniquePath];
		[self.content writeToFile:self.dumpedFilePath atomically:FALSE];
	}
}

#pragma mark -
#pragma mark Setup

// Set for example
// Style and background color
- (void)setupTableView
{
//	// Become tableView delegate and datasource
	self.tableView.delegate = self;
	if (!self.tableView.dataSource) {
		self.tableView.dataSource = self;
	}
}

// Set for example
// Color and items
- (void)setupNavigationBar
{
	// Nothing
}

// Set for example
// Color and items 
- (void)setupToolbar
{	
	// Nothing
}

- (void)setupDataSource
{
	// Nothing
}

// Perform first fetch
// Reload tableview when context save
- (void)setupCoreData
{
	if (self.fetchedResultsController) {
		NSError *error;
		if (![self.fetchedResultsController performFetch:&error]) {
			// Handle the error...
		}
	}
}

#pragma mark -
#pragma mark Editing Support

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	[super setEditing:editing animated:animated];
	
	[self.tableView setEditing:editing animated:animated];
}

#pragma mark -
#pragma mark fetchedResultsController Delegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark Subclassing

- (NSMutableArray *)content
{
	if (self.dataSource) {
		return self.dataSource.content;
	}
	
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	// Use your object
	//	id object = [self objectForIndexPath:indexPath forTableView:tableView];
	
}


#pragma mark -
#pragma mark  Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return [self numberOfSectionsForTableView:tableView];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	return [self numberOfRowsInSection:section forTableView:tableView];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *MyCellIdentifier = @"MyCellIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyCellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyCellIdentifier] autorelease];
    }
	
	//id object = [self objectForIndexPath:indexPath forTableView:tableView];
    
	// Configure the cell.
	
    return cell;
}

#pragma mark -
#pragma mark Table view methods helper

- (NSInteger)numberOfSectionsForTableView:(UITableView *)tableView
{
	if (self.fetchedResultsController && tableView == self.tableView) {
		return [[self.fetchedResultsController sections] count];
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
	if (self.fetchedResultsController && tableView == self.tableView) {
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section { 
    if (self.fetchedResultsController && tableView == self.tableView) {
		id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
		return [sectionInfo name];
	}
	return nil;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
   if (self.fetchedResultsController && tableView == self.tableView) {
		return [self.fetchedResultsController sectionIndexTitles];
	}
	return nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if (self.fetchedResultsController && tableView == self.tableView) {
		return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
	}
	return 0;
}

- (id)objectForIndexPath:(NSIndexPath *)indexPath forTableView:(UITableView *)tableView;
{
	if (self.dataSource && tableView == self.tableView) {
		return [self.dataSource objectForIndexPath:indexPath forTableView:tableView];
	}
	
	if (self.fetchedResultsController && tableView == self.tableView) {
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

- (NSString *)entityName
{
	if (self.dataSource) {
		return self.dataSource.entityName;
	}
	
	if (!_entityName) {
		_entityName = nil;
	}
	return _entityName;
}

#pragma mark -
#pragma mark Loading View

- (void)showLoadingViewForText:(NSString *)loadingText
{
	// Get view bounds
	CGRect rect = self.tableView.frame;
	// Check if there is already one loading view in place
	ODLoadingView *loadingView = (ODLoadingView *)[self.view viewWithTag:LoadingViewTag];
	if (!loadingView) {
		// Compute the loading view
		loadingView = [[ODLoadingView alloc]initWithFrame:rect];
		loadingView.tag = LoadingViewTag;
		// Add the view to the top of the gridView
		[self.view addSubview:loadingView];
		[loadingView release];
	} else {
		loadingView.frame = rect;
	}
	// Setup text
	if (loadingText) {
		loadingView.loadingLabel.text = loadingText;
	}
	// Animate the activity indicator
	[loadingView.activityIndicatorView startAnimating];
	
	// Lock the gridView scrollview
	self.tableView.scrollEnabled = FALSE;
}

- (void)hideLoadingView
{
	// Remove loading view
	ODLoadingView *loadingView = (ODLoadingView *)[self.view viewWithTag:LoadingViewTag];
	[loadingView.activityIndicatorView stopAnimating];
	[loadingView removeFromSuperview];
	// Unlock the tableview scrollview
	self.tableView.scrollEnabled = TRUE;
}

#pragma mark -
#pragma mark Build Next Url

- (NSURL *)buildNextUrlWithOffset:(NSInteger)offset limit:(NSInteger)limit offsetName:(NSString *)offsetName limitName:(NSString *)limitName urlString:(NSString *)urlString
{
	// Add the limit and offset
	// &start=10&limit=5
	NSString *newUrlString = [NSString stringWithFormat:@"%@&%@=%d&%@=%d",urlString, offsetName, offset, limitName, limit]; 
	// Construct the url
	return [NSURL URLWithString:newUrlString];
}

#pragma mark -
#pragma mark Error View

- (void)showErrorViewForText:(NSString *)errorText
{
	// Get view bounds
	CGRect rect = self.tableView.frame;
	// Check if there is already one error view in place
	ODLoadingView *errorView = (ODLoadingView *)[self.view viewWithTag:ErrorViewTag];
	if (!errorView) {
		errorView = [[ODLoadingView alloc]initWithFrame:rect];
		errorView.tag = ErrorViewTag;
		// Add the view to the top of the gridView
		[self.view addSubview:errorView];
		[errorView release];
	} else {
		errorView.frame = rect;
	}
	// Setup text
	if (errorText) {
		errorView.loadingLabel.text = errorText;
	}
	
	// Lock the gridView scrollview
	self.tableView.scrollEnabled = FALSE;
}

- (void)hideErrorView
{
	// Remove loading view
	ODLoadingView *errorView = (ODLoadingView *)[self.view viewWithTag:ErrorViewTag];
	[errorView removeFromSuperview];
	// Unlock the tableview scrollview
	self.tableView.scrollEnabled = TRUE;
}


#pragma mark -
#pragma mark Fetch Results Controlelr

- (NSFetchedResultsController *)fetchedResultsController {
	
	if (self.dataSource) {
		return self.dataSource.fetchedResultsController;
	}
	
	return nil;
}

#pragma mark -
#pragma mark Show Error

- (void)showUserErrorWithTitle:(NSString *)title message:(NSString *)message
{
	// Inform the user regarding problem
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title 
													message:message
												   delegate:nil cancelButtonTitle:nil 
										  otherButtonTitles:@"OK", nil];
	alert.delegate = self;
	[alert show];	
	[alert release];
}

#pragma mark -
#pragma mark Core Data

- (BOOL)saveContextAndHandleErrors 
{
	BOOL success = YES;
	
	if ([self.managedObjectContext hasChanges]) {
		for (id object in [self.managedObjectContext updatedObjects]) {
			if (![[object changedValues] count]) {
				[self.managedObjectContext refreshObject: object
											mergeChanges: NO];
			}
		}
		
		NSError* error = nil;
		if(![self.managedObjectContext save:&error]) {
			success = NO;
			DLog(@"Failed to save to data store: %@", [error localizedDescription]);
			NSArray* detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
			if(detailedErrors != nil && [detailedErrors count] > 0) {
				for(NSError* detailedError in detailedErrors) {
					DLog(@"  DetailedError: %@", [detailedError userInfo]);
				}
			}
			else {
				DLog(@"  %@", [error userInfo]);
			}
		} 
	}
	
	return success;  
}

#pragma mark -
#pragma mark Image downloading

- (BOOL)isContainerViewMoving:(BaseDataSource *)dataSource
{
	return (self.tableView.dragging == YES && self.tableView.decelerating == YES);
}

- (void)imageDownloaderShouldLoadImageAtUrl:(NSString *)imageUrl forIndex:(NSNumber *)index dataSource:(BaseDataSource *)dataSource
{
	//	id object = [self.dataSource.content objectAtIndex:[index integerValue]];		
	//	if (object.urlString) // avoid the download if url not there
	//	{
	//		[self startImageDownload:object.urlString forIndex:index resizeSize:CGSizeMake(50.0, 50.0)];
	//	}
}

- (void)imageDownloaderDidLoadImage:(UIImage *)image forIndex:(NSNumber *)index dataSource:(BaseDataSource *)dataSource
{
	
}

- (void)startImageDownload:(NSString *)url forIndex:(NSNumber *)index resizeSize:(CGSize)resizeSize;
{
	if (![self.imageDownloaders objectForKey:index]) 
    {
		ODImageDownloader *operation = [[ODImageDownloader alloc]initWithURL:[NSURL URLWithString:url]infoDictionary:nil];
		operation.index = index;
		operation.resizeSize = resizeSize;
		if (self.dataSource) {
			operation.imageDelegate = self.dataSource;
		} else {
			operation.imageDelegate = self;
		}
        [self.imageDownloadQueue addOperation:operation];
		[self.imageDownloaders setObject:operation forKey:index];
        [operation release];   
    }
}

// this method is used in case the user scrolled into a set of cells that don't have their app icons yet
- (void)loadImagesForOnscreenRows
{
	//    for (ODGridItemView *item in self.gridView.currentItems) {
	//		//id object = [self.content objectAtIndex:item.index];
	//		
	//		if (object.thumbnailURLString) // avoid the download if url not there
	//		{
	//			[self startImageDownload:object.thumbnailURLString forIndex:object.index];
	//		}
	//	}
}

// called by our ImageDownloader when an icon is ready to be displayed
- (void)imageDownloaderDidLoadImageWithInfo:(NSDictionary *)info
{
	// Refresh the item
	// UIImage *image = [UIImage imageWithData:image];
	// Save the image
	[self.imageDownloaders removeObjectForKey:[info valueForKey:@"index"]];
}


#pragma mark -
#pragma mark Deferred image loading (UIScrollViewDelegate)

// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
	{
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // terminate all pending download connections
	[self.imageDownloadQueue cancelAllOperations];
}

#pragma mark -
#pragma mark Restore Levels

- (void)restoreLevelWithSelectionArray:(NSArray *)selectionArray
{
	// nothing
}

#pragma mark -
#pragma mark Execut Method When Notification Fire

//help executing a method when a notification fire
- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object 
						change:(NSDictionary *)change 
					   context:(void *)context
{
	[self performSelector: (SEL)context withObject: change];
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
	
	[_object release];
	[_managedObjectContext release];
	[_entityName release];
	[_fetchedResultsController release];
	[_dataSource release];
	[_dumpedFilePath release];
	[_content release];
	[_tableView release];
	
    [super dealloc];
}


@end

