//
//  BaseGridViewController.m
//  ObjectiveDump
//
//  Created by Anthony Mittaz on 3/12/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import "BaseGridViewController.h"
#import "GloballyUniquePathStringAdditions.h"
#import "ODLoadingView.h"

#define LoadingViewTag 1034343
#define ErrorViewTag 1034354

@implementation BaseGridViewController


@synthesize gridView=_gridView;
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
	[self setupGridView];
	
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

- (void)setupGridView
{
	// Nothing
	self.gridView.delegate = self;
	if (!self.gridView.dataSource) {
		self.gridView.dataSource = self;
	}
}

- (void)setupDataSource
{
	// Nothing
}

// Perform first fetch
// Reload gridView when context save
- (void)setupCoreData
{
	// Nothing
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

- (void)gridView:(ODGridView *)gridView didSelectItemAtIndex:(NSInteger)index {
    
	// Use your object
}


#pragma mark -
#pragma mark  Grid View methods

- (NSInteger)numberOfItemsInGridView:(ODGridView *)gridView;
{
	// Check if content first element return array or not
	// If yes, gridView has more than one section
	if (self.content && self.content.count > 0
		&& [[self.content objectAtIndex:0]respondsToSelector:@selector(objectAtIndex:)]) {
		return self.content.count;
	}
	return 0;
}

- (ODGridItemView *)gridView:(ODGridView *)gridView itemForIndex:(NSInteger)index;
{
	//id object = [self.content objectAtIndex:index];
	
	ODGridItemView *gridItemView = [gridView dequeueReusableItem];
	if (!gridItemView) {
		gridItemView = [ODGridItemView gridItem];
	}
	
	gridItemView.nameLabel.text = nil;
	gridItemView.imageView.image = nil;
	
	if (self.gridView.dragging == NO && self.gridView.decelerating == NO) {
		//[self startImageDownload:nil forIndex:[NSNumber numberWithInteger:index] resizeSize:CGSizeMake(50.0, 50.0)];
	}
	
	return gridItemView;
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
	CGRect rect = self.gridView.frame;
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
	self.gridView.scrollEnabled = FALSE;
}

- (void)hideLoadingView
{
	// Remove loading view
	ODLoadingView *loadingView = (ODLoadingView *)[self.view viewWithTag:LoadingViewTag];
	[loadingView.activityIndicatorView stopAnimating];
	[loadingView removeFromSuperview];
	// Unlock the gridView scrollview
	self.gridView.scrollEnabled = TRUE;
}

#pragma mark -
#pragma mark Build Next Url

- (NSURL *)buildNextUrlWithOffset:(NSInteger)offset limit:(NSInteger)limit urlString:(NSString *)urlString
{
	// Add the limit and offset
	// &start=10&limit=5
	NSString *newUrlString = [NSString stringWithFormat:@"%@&start=%d&limit=%d",urlString, offset, limit]; 
	// Construct the url
	return [NSURL URLWithString:newUrlString];
}

#pragma mark -
#pragma mark Error View

- (void)showErrorViewForText:(NSString *)errorText
{
	// Get view bounds
	CGRect rect = self.gridView.frame;
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
	self.gridView.scrollEnabled = FALSE;
}

- (void)hideErrorView
{
	// Remove loading view
	ODLoadingView *errorView = (ODLoadingView *)[self.view viewWithTag:ErrorViewTag];
	[errorView removeFromSuperview];
	// Unlock the gridView scrollview
	self.gridView.scrollEnabled = TRUE;
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

- (BOOL)isContainerViewMoving:(BaseGridViewDataSource *)dataSource
{
	return (self.gridView.dragging == YES && self.gridView.decelerating == YES);
}

- (void)imageDownloaderShouldLoadImageAtUrl:(NSString *)imageUrl forIndex:(NSNumber *)index dataSource:(BaseGridViewDataSource *)dataSource
{
//	id object = [self.dataSource.content objectAtIndex:[index integerValue]];		
//	if (object.urlString) // avoid the download if url not there
//	{
//		[self startImageDownload:object.urlString forIndex:index resizeSize:CGSizeMake(50.0, 50.0)];
//	}
}

- (void)imageDownloaderDidLoadImage:(UIImage *)image forIndex:(NSNumber *)index dataSource:(BaseGridViewDataSource *)dataSource
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
- (void)imageDownloaderDidLoadImage:(UIImage *)image forIndex:(NSNumber *)index;
{
	// Refresh the item
	// Save the image
	[self.imageDownloaders removeObjectForKey:index];
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
	
	[_imageDownloaders release];
	[_imageDownloadQueue release];
	[_object release];
	[_managedObjectContext release];
	[_entityName release];
	[_dataSource release];
	[_dumpedFilePath release];
	[_content release];
	[_gridView release];
	
    [super dealloc];
}


@end
