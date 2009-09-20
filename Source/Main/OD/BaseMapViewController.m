//
//  BaseMapViewController.m
//  ObjectiveDump
//
//  Created by Anthony Mittaz on 25/08/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import "BaseMapViewController.h"
#import "BaseMapViewDataSource.h"
#import "GloballyUniquePathStringAdditions.h"
#import "ODLoadingView.h"
#import "BasePinAnnotation.h"

#define LoadingViewTag 1034343
#define ErrorViewTag 1034354

@implementation BaseMapViewController

@synthesize mapView=_mapView;
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
	
	// Set for example
	// Background color
	[self setupMapView];
	
	// If using data source
	[self setupDataSource];
	
	// If using core data
	[self setupCoreData];
	
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
- (void)setupMapView
{
	//	// Become tableView delegate and datasource
	self.mapView.delegate = self;
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
	CGRect rect = self.view.bounds;
	// Check if there is already one loading view in place
	ODLoadingView *loadingView = (ODLoadingView *)[self.mapView viewWithTag:LoadingViewTag];
	if (!loadingView) {
		// Compute the loading view
		loadingView = [[ODLoadingView alloc]initWithFrame:rect];
		loadingView.tag = LoadingViewTag;
		// Add the view to the top of the tableview
		[self.mapView addSubview:loadingView];
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
	self.mapView.scrollEnabled = FALSE;
}

- (void)hideLoadingView
{
	// Remove loading view
	ODLoadingView *loadingView = (ODLoadingView *)[self.mapView viewWithTag:LoadingViewTag];
	[loadingView.activityIndicatorView stopAnimating];
	[loadingView removeFromSuperview];
	self.mapView.scrollEnabled = TRUE;
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
	CGRect rect = self.view.bounds;
	// Check if there is already one error view in place
	ODLoadingView *errorView = (ODLoadingView *)[self.mapView viewWithTag:ErrorViewTag];
	if (!errorView) {
		errorView = [[ODLoadingView alloc]initWithFrame:rect];
		errorView.tag = ErrorViewTag;
		// Add the view to the top of the tableview
		[self.mapView addSubview:errorView];
		[errorView release];
	} else {
		errorView.frame = rect;
	}
	// Setup text
	if (errorText) {
		errorView.loadingLabel.text = errorText;
	}
	
	// Lock the tableview scrollview
	self.mapView.scrollEnabled = FALSE;
}

- (void)hideErrorView
{
	// Remove loading view
	ODLoadingView *errorView = (ODLoadingView *)[self.mapView viewWithTag:ErrorViewTag];
	[errorView removeFromSuperview];
	// Unlock the tableview scrollview
	self.mapView.scrollEnabled = TRUE;
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
#pragma mark MapKit delegate

- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView
{
	[[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:TRUE];
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
	[[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:FALSE];
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error
{
	[[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:FALSE];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	if ([annotation respondsToSelector:@selector(objectID)]) {
		static NSString *defaultPinID = @"DefaultPinID";
		
		MKPinAnnotationView *mkav = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
		if (mkav == nil) {
			mkav = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:defaultPinID] autorelease];
			mkav.canShowCallout = TRUE;
			mkav.pinColor = MKPinAnnotationColorRed;
			UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
			mkav.rightCalloutAccessoryView = button;
			mkav.animatesDrop = TRUE;
		}
		
		return mkav;
	}
	return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
	// Get the annotation link to the view where user just pressed
	BasePinAnnotation *annotation = (BasePinAnnotation *)view.annotation;
	
	// Check if is really a product pint annotion
	// By checking if annotion got an objectID
	if ([annotation respondsToSelector:@selector(objectID)] && annotation.objectID) {
		// Get the managed object context for the controller
		// Reuse the same managed object context as the given object
//		NSManagedObject *givenObject = (NSManagedObject *)self.object;
//		NSManagedObjectContext *context = givenObject.managedObjectContext;
//		// Get the product at shop from the db using the unique objectID
//		id object = [context objectWithID:annotation.objectID];
	}
}

#pragma mark -
#pragma mark Annotation helper

- (void)addAnnotationWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title subtitle:(NSString *)subtitle objectID:(NSManagedObjectID *)objectID
{
	BasePinAnnotation *annotation = [[BasePinAnnotation alloc]initWithCoordinate:coordinate];
	annotation.objectID = objectID;
	annotation.title = title;
	annotation.subtitle = subtitle;
	[self.mapView addAnnotation:annotation];
	[annotation release];
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
	[_dataSource release];
	[_dumpedFilePath release];
	[_content release];
	[_mapView release];
	
    [super dealloc];
}



@end
