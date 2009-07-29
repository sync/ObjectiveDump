//
//  ODShowMoreCell.m
//  ObjectiveDump
//
//  Created by Anthony Mittaz on 29/07/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import "ODShowMoreCell.h"

#define HorizontallOffset 50.0
#define ActivityWidth 20.0
#define HorizontallTextActivityOffset 10.0
#define FontDiff 6.0
#define VerticalOffset 7.0

@implementation ODShowMoreCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		self.accessoryType = UITableViewCellAccessoryNone;
    }
    return self;
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
	
	// Only if title label is set
	if (_moreTextLabel) {
		// Set the more label frame to use all the half height
		// With a left offset
		self.moreTextLabel.frame = CGRectMake(rect.origin.x + HorizontallOffset,
											  rect.origin.y + roundf((rect.size.height - self.moreTextLabel.font.capHeight - FontDiff) / 2.0) - VerticalOffset, 
											  rect.size.width - HorizontallOffset - HorizontallTextActivityOffset - ActivityWidth, 
											  roundf(self.moreTextLabel.font.capHeight + FontDiff));
	}
	
	if (_showingTextLabel) {
		// Set the showing label frame to use all the half height
		// With a left offset
		self.showingTextLabel.frame = CGRectMake(rect.origin.x + HorizontallOffset,
												 rect.origin.y + roundf((rect.size.height - self.showingTextLabel.font.capHeight - FontDiff) / 2.0) + VerticalOffset, 
												 rect.size.width - HorizontallOffset - HorizontallTextActivityOffset - ActivityWidth, 
												 roundf(self.showingTextLabel.font.capHeight + FontDiff));
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

#pragma mark -
#pragma mark Reuse

- (void)prepareForReuse
{
	[super prepareForReuse];
	
	// Reset more text
	if (_moreTextLabel) {
		self.moreTextLabel.text = nil;
	}
	// Reset showing text 
	if (_showingTextLabel) {
		self.showingTextLabel.text = nil;
	}
	
	// Remove animation
	if (_activityIndicatorView) {
		[self.activityIndicatorView stopAnimating];
	}
}


- (void)dealloc {
    [_moreTextLabel release];
	[_showingTextLabel release];
	[_activityIndicatorView release];
	
	[super dealloc];
}


@end
