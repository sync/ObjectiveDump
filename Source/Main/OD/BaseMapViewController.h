//
//  BaseMapViewController.h
//  ObjectiveDump
//
//  Created by Anthony Mittaz on 25/08/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreData/CoreData.h>
#import "BaseMapViewDataSource.h"
#import "BaseViewController.h"

@protocol BaseMapViewControllerSubclass <NSObject>

@optional

// Non persistent content
@property (nonatomic, readonly) NSMutableArray *content;

@end


@interface BaseMapViewController : UIViewController <UIAlertViewDelegate, BaseViewControllerSubclass, BaseMapViewControllerSubclass, MKMapViewDelegate>{
	// MapView
	MKMapView *_mapView;
	
	// Non persitent content
	NSMutableArray *_content;
	NSString *_dumpedFilePath;
	
	// Persitent content
	NSString *_entityName;
	
	// Get the context
	NSManagedObjectContext *_managedObjectContext;
	
	BaseMapViewDataSource *_dataSource;
	
	id _object;
	
	BOOL _viewDidLoadCalled;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;

@property (nonatomic, copy) NSString *dumpedFilePath;
@property (nonatomic, retain) BaseMapViewDataSource *dataSource;
@property (nonatomic, retain) id object;
@property (nonatomic) BOOL viewDidLoadCalled;

// Loading View
- (void)showLoadingViewForText:(NSString *)loadingText;
- (void)hideLoadingView;

// Error View
- (void)showErrorViewForText:(NSString *)errorText;
- (void)hideErrorView;

// Build Next Url
- (NSURL *)buildNextUrlWithOffset:(NSInteger)offset limit:(NSInteger)limit urlString:(NSString *)urlString;

// Annotation helper
- (id)addAnnotationWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title subtitle:(NSString *)subtitle objectID:(NSManagedObjectID *)objectID;

// Core Data
- (BOOL)saveContextAndHandleErrors;

@end
