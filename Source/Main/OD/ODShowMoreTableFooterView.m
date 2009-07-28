//
//  ODShowMoreTableFooterView.m
//  ObjectiveDump
//
//  Created by Anthony Mittaz on 24/07/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import "ODShowMoreTableFooterView.h"

#define HorizontallOffset 50.0
#define ActivityWidth 20.0
#define HorizontallTextActivityOffset 10.0
#define FontDiff 6.0
#define VerticalOffset 7.0

@implementation ODShowMoreTableFooterView


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

- (UILabel *)moreTextLabel
{
	if (!_moreTextLabel) {
		_moreTextLabel = [[UILabel alloc]initWithFrame:CGRectZero];
		_moreTextLabel.backgroundColor = [UIColor clearColor];
		_moreTextLabel.textAlignment = UITextAlignmentLeft;
		_moreTextLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
		[self addSubview:_moreTextLabel];
	}
	return _moreTextLabel;
}

- (UILabel *)showingTextLabel
{
	if (!_showingTextLabel) {
		_showingTextLabel = [[UILabel alloc]initWithFrame:CGRectZero];
		_showingTextLabel.backgroundColor = [UIColor clearColor];
		_showingTextLabel.textAlignment = UITextAlignmentLeft;
		_showingTextLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
		[self addSubview:_showingTextLabel];
	}
	return _showingTextLabel;
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
	
	// Only if title label is set
	if (_moreTextLabel) {
		// Set the more label frame to use all the half height
		// With a left offset
		self.moreTextLabel.frame = CGRectMake(rect.origin.x + HorizontallOffset,
											  rect.origin.y + round((rect.size.height - self.moreTextLabel.font.capHeight - FontDiff) / 2.0) - VerticalOffset, 
											  rect.size.width - HorizontallOffset - HorizontallTextActivityOffset - ActivityWidth, 
											  self.moreTextLabel.font.capHeight + FontDiff);
	}
	
	if (_showingTextLabel) {
		// Set the showing label frame to use all the half height
		// With a left offset
		self.showingTextLabel.frame = CGRectMake(rect.origin.x + HorizontallOffset,
											  rect.origin.y + round((rect.size.height - self.showingTextLabel.font.capHeight - FontDiff) / 2.0) + VerticalOffset, 
											  rect.size.width - HorizontallOffset - HorizontallTextActivityOffset - ActivityWidth, 
											  self.showingTextLabel.font.capHeight + FontDiff);
	}
	
	// Only if the activity indicator is set
	if (_activityIndicatorView) {
		// Set the activity indicator to be centered horizontall
		// And higher than center vertically
		// Get the activiy indicator frame
		CGRect activityRect = self.activityIndicatorView.frame;
		self.activityIndicatorView.frame = CGRectMake(rect.origin.x +  rect.size.width - (HorizontallOffset + HorizontallTextActivityOffset + ActivityWidth),
													  (rect.size.height - activityRect.size.height) / 2,
													  activityRect.size.width,
													  activityRect.size.height);
	}
}


- (void)dealloc {
	
    [_activityIndicatorView release];
	[_showingTextLabel release];
	[_moreTextLabel release];
	[_backgroundImageView release];
	
	[super dealloc];
}


@end
