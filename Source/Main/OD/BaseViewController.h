//
//  BaseViewController.h
//  
//
//  Created by Anthony Mittaz on 6/02/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "BaseViewDataSource.h"

@protocol BaseViewControllerSubclass <NSObject>

@optional

// Setting up 
- (void)setupCustomInitialisation;
- (void)setupTableView;
- (void)setupMapView;
- (void)setupGridView;
- (void)setupNavigationBar;
- (void)setupToolbar;
- (void)setupDataSource;
- (void)setupCoreData;

// Restore levels
- (void)restoreLevelWithSelectionArray:(NSArray *)selectionArray;

// Show error to user
// Cannot cancel, just ok button
- (void)showUserErrorWithTitle:(NSString *)title message:(NSString *)message;

// Get the context
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

// Persistent content
@property (nonatomic, readonly) NSString *entityName;

@end



@interface BaseViewController : UIViewController <BaseViewControllerSubclass>{
	id _object;
	
	BOOL _viewDidLoadCalled;
	
	NSManagedObjectContext *_managedObjectContext;
	
	BaseViewDataSource *_dataSource;
}

@property (nonatomic, retain) id object;
@property (nonatomic) BOOL viewDidLoadCalled;
@property (nonatomic, retain) BaseViewDataSource *dataSource;

// Loading View
- (void)showLoadingViewForText:(NSString *)loadingText;
- (void)hideLoadingView;

// Error View
- (void)showErrorViewForText:(NSString *)errorText;
- (void)hideErrorView;

// Core Data
- (BOOL)saveContextAndHandleErrors;

@end
