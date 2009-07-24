//
//  ODShowMoreTableFooterView.h
//  ObjectiveDump
//
//  Created by Anthony Mittaz on 24/07/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TapDetectingView.h"

@interface ODShowMoreTableFooterView : TapDetectingView {
	UIImageView *_backgroundImageView;
	UILabel *_moreTextLabel;
	UILabel *_showingTextLabel;
	UIActivityIndicatorView *_activityIndicatorView;
}

@property (nonatomic, readonly) UIImageView *backgroundImageView;
@property (nonatomic, readonly) UILabel *moreTextLabel;
@property (nonatomic, readonly) UILabel *showingTextLabel;
@property (nonatomic, readonly) UIActivityIndicatorView *activityIndicatorView;

- (void)setupCustomInitialisation;

@end
