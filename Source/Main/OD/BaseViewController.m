//
//  BaseViewController.m
//  
//
//  Created by Anthony Mittaz on 6/02/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import "BaseViewController.h"
#import "ODLoadingView.h"

#define LoadingViewTag 1034343
#define ErrorViewTag 1034354

@implementation BaseViewController

@synthesize object=_object;
@synthesize viewDidLoadCalled=_viewDidLoadCalled;
@synthesize managedObjectContext=_managedObjectContext;
@synthesize dataSource=_dataSource;

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
	
	self.viewDidLoadCalled = TRUE;
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

#pragma mark -
#pragma mark Setup

// Set for example
// Style and background color
- (void)setupTableView
{
	// Nothing
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
	// Nothing
}

#pragma mark -
#pragma mark Image downloading

- (void)startImageDownload:(NSString *)url forIndex:(NSNumber *)index resizeSize:(CGSize)resizeSize;
{
    // Search on operation queue list if not found create new one
	if (![self.imageDownloaders objectForKey:index]) 
    {
		ODImageDownloader *operation = [[ODImageDownloader alloc]initWithURL:[NSURL URLWithString:url]infoDictionary:nil];
		operation.index = index;
		operation.resizeSize = resizeSize;
		operation.imageDelegate = self;
        [self.imageDownloadQueue addOperation:operation];
		[self.imageDownloaders setObject:operation forKey:index];
        [operation release];   
    }
}

// called by our ImageDownloader when an icon is ready to be displayed
- (void)imageDownloaderDidLoadImage:(UIImage *)image forIndex:(NSNumber *)index;
{
	// Refresh the item
	// Save the image
	[self.imageDownloaders removeObjectForKey:index];
}

#pragma mark -
#pragma mark Loading View

- (void)showLoadingViewForText:(NSString *)loadingText
{
	// Get view bounds
	CGRect rect = self.view.frame;
	// Check if there is already one loading view in place
	ODLoadingView *loadingView = (ODLoadingView *)[self.view viewWithTag:LoadingViewTag];
	if (!loadingView) {
		// Compute the loading view
		loadingView = [[ODLoadingView alloc]initWithFrame:rect];
		loadingView.tag = LoadingViewTag;
		// Add the view to the top of the tableview
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
}

- (void)hideLoadingView
{
	// Remove loading view
	ODLoadingView *loadingView = (ODLoadingView *)[self.view viewWithTag:LoadingViewTag];
	[loadingView.activityIndicatorView stopAnimating];
	[loadingView removeFromSuperview];
}

#pragma mark -
#pragma mark Error View

- (void)showErrorViewForText:(NSString *)errorText
{
	// Get view bounds
	CGRect rect = self.view.frame;
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
}

- (void)hideErrorView
{
	// Remove loading view
	ODLoadingView *errorView = (ODLoadingView *)[self.view viewWithTag:ErrorViewTag];
	[errorView removeFromSuperview];
}

#pragma mark -
#pragma mark Restore Levels

- (void)restoreLevelWithSelectionArray:(NSArray *)selectionArray
{
	// nothing
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
	
	[_imageDownloadQueue release];
	[_imageDownloaders release];
	[_dataSource release];
	[_managedObjectContext release];
    [_object release];
	[super dealloc];
}

@end
