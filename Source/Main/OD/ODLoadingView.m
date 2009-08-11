//
//  ODLoadingView.m
//  ObjectiveDump
//
//  Created by Anthony Mittaz on 13/07/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import "ODLoadingView.h"

#define VerticalDiff 20.0

@implementation ODLoadingView

// The designated initializer. Override to perform setup that is required before the view is loaded.
// Only when xibless (interface buildder)
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
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
	// Initialization code
	// Nothing
	self.backgroundColor = [UIColor whiteColor];
}



- (UIImageView *)backgroundImageView
{
	if (!_backgroundImageView) {
		_backgroundImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
		[self addSubview:_backgroundImageView];
	}
	return _backgroundImageView;
}

- (UIActivityIndicatorView *)activityIndicatorView
{
	if (!_activityIndicatorView) {
		_activityIndicatorView = [[UIActivityIndicatorView alloc]
								  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		[self addSubview:_activityIndicatorView];
	}
	return _activityIndicatorView;
}

- (UILabel *)loadingLabel
{
	if (!_loadingLabel) {
		_loadingLabel = [[UILabel alloc]initWithFrame:CGRectZero];
		_loadingLabel.backgroundColor = [UIColor clearColor];
		_loadingLabel.textAlignment = UITextAlignmentCenter;
		_loadingLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
		_loadingLabel.numberOfLines = 0;
		_loadingLabel.adjustsFontSizeToFitWidth = FALSE;
		[self addSubview:_loadingLabel];
	}
	return _loadingLabel;
}

#pragma mark -
#pragma mark Layout

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	// Get the bounds of view
	CGRect rect = self.bounds;
	
	// Only if background image is set
	if (_backgroundImageView) {
		// Set the background image frame to use all the space
		self.backgroundImageView.frame = rect;
	}
	
	// Only if the activity indicator is set
	if (_activityIndicatorView) {
		// Set the activity indicator to be centered horizontall
		// And higher than center vertically
		// Get the activiy indicator frame
		CGRect activityRect = self.activityIndicatorView.frame;
		self.activityIndicatorView.frame = CGRectMake((rect.size.width - activityRect.size.width) / 2,
													  (rect.size.height - activityRect.size.height) / 2 - VerticalDiff,
													  activityRect.size.width,
													  activityRect.size.height);
	}
	
	// Only if title label is set
	if (_loadingLabel) {
		// Set the title label frame to use all the size
		// With a left/right offset
		self.loadingLabel.frame = rect;
	}
}

- (void)dealloc {
	[_activityIndicatorView release];
	[_loadingLabel release];
	[_backgroundImageView release];
	
    [super dealloc];
}


@end
