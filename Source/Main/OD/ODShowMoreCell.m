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
#define FontDiff 6.0
#define VerticalOffset 7.0
#define TextActivityDiff 10.0

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
	
	CGRect moreTextLabelFrame = CGRectZero;
	CGRect showingTextLabelFrame = CGRectZero;
	
	CGFloat widdest = 0;
	
	// Calculate the width of 
	// The more text label
	if (_moreTextLabel) {
		// Default frame
		moreTextLabelFrame = CGRectMake(rect.origin.x,
									   rect.origin.y + roundf((rect.size.height - self.moreTextLabel.font.capHeight - FontDiff) / 2.0) - VerticalOffset, 
									   rect.size.width - ActivityWidth, 
									   roundf(self.moreTextLabel.font.capHeight + FontDiff));
		
		// Get the text width
		CGRect textFrame = [self.moreTextLabel textRectForBounds:moreTextLabelFrame limitedToNumberOfLines:self.moreTextLabel.numberOfLines];
		
		if (textFrame.size.width > widdest) {
			widdest = textFrame.size.width;
		}
		
	}
	
	// Calculate the width of 
	// The showing text label
	if (_showingTextLabel) {
		// Default frame
		showingTextLabelFrame = CGRectMake(rect.origin.x,
									   rect.origin.y + roundf((rect.size.height - self.showingTextLabel.font.capHeight - FontDiff) / 2.0) + VerticalOffset, 
									   rect.size.width - ActivityWidth, 
									   roundf(self.showingTextLabel.font.capHeight + FontDiff));
		
		// Get the text width
		CGRect textFrame = [self.showingTextLabel textRectForBounds:showingTextLabelFrame limitedToNumberOfLines:self.showingTextLabel.numberOfLines];
		
		if (textFrame.size.width > widdest) {
			widdest = textFrame.size.width;
		}
	
	}
	
	if (_moreTextLabel) {
		self.moreTextLabel.frame = CGRectMake(moreTextLabelFrame.origin.x + roundf((rect.size.width - widdest) / 2.0), 
											  moreTextLabelFrame.origin.y, 
											  moreTextLabelFrame.size.width - roundf((rect.size.width - widdest) / 2.0),
											  moreTextLabelFrame.size.height);
	}
	
	if (_showingTextLabel) {
		self.showingTextLabel.frame = CGRectMake(showingTextLabelFrame.origin.x + roundf((rect.size.width - widdest) / 2.0), 
												 showingTextLabelFrame.origin.y, 
												 showingTextLabelFrame.size.width - roundf((rect.size.width - widdest) / 2.0),
												 showingTextLabelFrame.size.height);
	}
	
	// Only if the activity indicator is set
	if (_activityIndicatorView) {
		// Set the activity indicator to be centered horizontall
		// And higher than center vertically
		// Get the activiy indicator frame
		CGRect activityRect = self.activityIndicatorView.frame;
		self.activityIndicatorView.frame = CGRectMake(rect.origin.x +  roundf((rect.size.width - widdest) / 2.0) + widdest + TextActivityDiff,
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
