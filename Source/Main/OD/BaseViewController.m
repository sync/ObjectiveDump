//
//  BaseViewController.m
//  
//
//  Created by Anthony Mittaz on 6/02/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import "BaseViewController.h"
#import "ODLoadingView.h"

#define LoadingViewTag 1035343

@implementation BaseViewController

@synthesize object=_object;
@synthesize viewDidLoadCalled=_viewDidLoadCalled;
@synthesize managedObjectContext=_managedObjectContext;

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

#pragma mark -
#pragma mark Loading View

- (void)showLoadingViewForText:(NSString *)loadingText
{
	// Get view bounds
	CGRect rect = self.view.bounds;
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
	
	[_managedObjectContext release];
    [_object release];
	[super dealloc];
}

@end
