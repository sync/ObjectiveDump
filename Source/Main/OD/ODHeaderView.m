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

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		// Add the background view
		[self addSubview:self.backgroundImageView];
		// Add the title view
		[self addSubview:self.titleLabel];
		
		// Set the offset to be 5.0;
		self.leftRightOffset = 5.0;
    }
    return self;
}

- (UIImageView *)backgroundImageView
{
	if (!_backgroundImageView) {
		_backgroundImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
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
