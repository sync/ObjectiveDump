//
//  BaseViewController.h
//  
//
//  Created by Anthony Mittaz on 6/02/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BaseViewControllerSubclass <NSObject>

@optional

// Setting up 
- (void)setupCustomInitialisation;
- (void)setupTableView;
- (void)setupMapView;
- (void)setupNavigationBar;
- (void)setupToolbar;

// Restore levels
- (void)restoreLevelWithSelectionArray:(NSArray *)selectionArray;

// Show error to user
// Cannot cancel, just ok button
- (void)showUserErrorWithTitle:(NSString *)title message:(NSString *)message;

@end



@interface BaseViewController : UIViewController <BaseViewControllerSubclass>{
	id _object;
}

@property (nonatomic, retain) id object;

// Loading View
- (void)showLoadingViewForText:(NSString *)loadingText;
- (void)hideLoadingView;

@end
