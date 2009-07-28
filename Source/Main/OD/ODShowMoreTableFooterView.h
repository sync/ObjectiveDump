//
//  ODShowMoreTableFooterView.h
//  ObjectiveDump
//
//  Created by Anthony Mittaz on 24/07/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ODShowMoreTableFooterView : UIControl {
	UIImageView *_backgroundImageView;
	UIImage *_backgroundImage;
	UIImage *_selectedBackgroundImage;
	UILabel *_moreTextLabel;
	UILabel *_showingTextLabel;
	UIActivityIndicatorView *_activityIndicatorView;
	
	UIColor *_selectedBackgroundColor;
	UIColor *_previousBackgroundColor;
}

@property (nonatomic, readonly) UIImageView *backgroundImageView;
@property (nonatomic, retain) UIImage *backgroundImage;
@property (nonatomic, retain) UIImage *selectedBackgroundImage;
@property (nonatomic, readonly) UILabel *moreTextLabel;
@property (nonatomic, readonly) UILabel *showingTextLabel;
@property (nonatomic, readonly) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, retain) UIColor *selectedBackgroundColor;
@property (nonatomic, retain) UIColor *previousBackgroundColor;

- (void)setupCustomInitialisation;

@end
