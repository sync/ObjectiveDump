//
//  BaseViewController.h
//  
//
//  Created by Anthony Mittaz on 6/02/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BaseViewController : UIViewController {
	ObjectiveDumpAppDelegate *_appDelegate;
}

@property (nonatomic, readonly) ObjectiveDumpAppDelegate *appDelegate;

// Setting up 
- (void)setupTableView;
- (void)setupNavigationBar;
- (void)setupToolbar;

// Restore levels
- (void)restoreLevelWithSelectionArray:(NSArray *)selectionArray;

// Show error to user
// Cannot cancel, just ok button
- (void)showUserErrorWithTitle:(NSString *)title message:(NSString *)message;

// Show loading view
// Possiblity to add a message
// Like loading...
- (void)showLoadingView:(BOOL)show withText:(NSString *)text;

@end
