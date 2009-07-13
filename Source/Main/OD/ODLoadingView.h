//
//  ODLoadingView.h
//  ObjectiveDump
//
//  Created by Anthony Mittaz on 13/07/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ODLoadingView : UIView {
	UIImageView *_backgroundImageView;
	UIActivityIndicatorView *_activityIndicatorView;
	UILabel *_loadingLabel;

}

@property (nonatomic, readonly) UIImageView *backgroundImageView;
@property (nonatomic, readonly) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, readonly) UILabel *loadingLabel;

- (void)setupCustomInitialisation;

@end
