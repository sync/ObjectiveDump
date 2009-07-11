//
//  ODHeaderView.m
//  ObjectiveDump
//
//  Created by Anthony Mittaz on 7/07/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import "ODHeaderView.h"

@implementation ODHeaderView

@synthesize leftRightOffset=_leftRightOffset;

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
	// Set the offset to be 5.0;
	self.leftRightOffset = 5.0;
	
}



- (UIImageView *)backgroundImageView
{
	if (!_backgroundImageView) {
		_backgroundImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
		[self addSubview:_backgroundImageView];
	}
	return _backgroundImageView;
}

- (UILabel *)titleLabel
{
	if (!_titleLabel) {
		_titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
		_titleLabel.backgroundColor = [UIColor clearColor];
		_titleLabel.textAlignment = UITextAlignmentCenter;
		_titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
		[self addSubview:_titleLabel];
	}
	return _titleLabel;
}

#pragma mark -
#pragma mark Layout

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	// Get the bounds of view
	CGRect rect = self.bounds;
	
	// Set the background image frame to use all the space
	self.backgroundImageView.frame = rect;
	
	// Set the title label frame to use all the size
	// With a left/right offset
	self.titleLabel.frame = CGRectMake(rect.origin.x + self.leftRightOffset, 
									   rect.origin.y, 
									   rect.size.width - 2 * self.leftRightOffset, 
									   rect.size.height);
}

- (void)dealloc {
	[_titleLabel release];
	[_backgroundImageView release];
	
    [super dealloc];
}


@end
