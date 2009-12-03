//
//  BaseViewController.h
//  
//
//  Created by Anthony Mittaz on 6/02/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@protocol BaseViewControllerSubclass <NSObject>

@optional

// Setting up 
- (void)setupCustomInitialisation;
- (void)setupTableView;
- (void)setupMapView;
- (void)setupGridView;
- (void)setupNavigationBar;
- (void)setupToolbar;

// Restore levels
- (void)restoreLevelWithSelectionArray:(NSArray *)selectionArray;

// Show error to user
// Cannot cancel, just ok button
- (void)showUserErrorWithTitle:(NSString *)title message:(NSString *)message;

// Get the context
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end



@interface BaseViewController : UIViewController <BaseViewControllerSubclass>{
	id _object;
	
	BOOL _viewDidLoadCalled;
	
	NSManagedObjectContext *_managedObjectContext;
}

@property (nonatomic, retain) id object;
@property (nonatomic) BOOL viewDidLoadCalled;

// Loading View
- (void)showLoadingViewForText:(NSString *)loadingText;
- (void)hideLoadingView;

// Core Data
- (BOOL)saveContextAndHandleErrors;

@end
