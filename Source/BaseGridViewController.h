//
//  BaseGridViewController.h
//  ObjectiveDump
//
//  Created by Anthony Mittaz on 2/12/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "BaseViewController.h"
#import "ODGridView.h"
#import "BaseGridViewDataSource.h"

@protocol BaseGridViewControllerSubclass <NSObject>

@optional

// Non persistent content
@property (nonatomic, readonly) NSMutableArray *content;

// Persistent content
@property (nonatomic, readonly) NSString *entityName;

// Get the context
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

// Setting up 
- (void)setupDataSource;
- (void)setupCoreData;

@end


@interface BaseGridViewController : UIViewController <UIAlertViewDelegate, BaseViewControllerSubclass, BaseGridViewControllerSubclass, ODGridViewDataSource, ODGridViewDelegate, UIScrollViewDelegate> {
	
	ODGridView *_gridView;
	
	// Non persitent content
	NSMutableArray *_content;
	NSString *_dumpedFilePath;
	
	// Persitent content
	NSString *_entityName;
	
	// Get the context
	NSManagedObjectContext *_managedObjectContext;
	
	BaseGridViewDataSource *_dataSource;
	
	id _object;
	
	BOOL _viewDidLoadCalled;
}

@property (nonatomic, retain) ODGridView *gridView;
@property (nonatomic, copy) NSString *dumpedFilePath;
@property (nonatomic, retain) BaseGridViewDataSource *dataSource;
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
// Core Data
- (BOOL)saveContextAndHandleErrors;

@end
