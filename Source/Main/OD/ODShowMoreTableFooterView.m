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

@synthesize previousBackgroundColor=_previousBackgroundColor;
@synthesize selectedBackgroundColor=_selectedBackgroundColor;
@synthesize backgroundImage=_backgroundImage;
@synthesize selectedBackgroundImage=_selectedBackgroundImage;


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
	// Set the background color
	self.backgroundColor = [UIColor whiteColor];
	// Set the selected background color
	self.selectedBackgroundColor = [UIColor blueColor];
}

- (UIImageView *)backgroundImageView
{
	if (!_backgroundImageView) {
		_backgroundImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
		_backgroundImageView.image = self.backgroundImage;
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
#pragma mark Highlighted:

//- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
//{
//	if (_showingTextLabel) {
//		self.showingTextLabel.highlighted = TRUE;
//	}
//	
//	if (_moreTextLabel) {
//		self.moreTextLabel.highlighted = TRUE;
//	}
//	
//	// Remember the previous background color
//	self.previousBackgroundColor = self.backgroundColor;
//	
//	// Set the new background color
//	self.backgroundColor = self.selectedBackgroundColor;
//	
//	return [super beginTrackingWithTouch:touch withEvent:event];
//}
//
//- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
//{
//	if (_showingTextLabel) {
//		self.showingTextLabel.highlighted = FALSE;
//	}
//	
//	if (_moreTextLabel) {
//		self.moreTextLabel.highlighted = FALSE;
//	}
//	
//	self.backgroundColor = self.previousBackgroundColor;
//	
//	return NO;
//}
//
//- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
//{
//	if (_showingTextLabel) {
//		self.showingTextLabel.highlighted = FALSE;
//	}
//	
//	if (_moreTextLabel) {
//		self.moreTextLabel.highlighted = FALSE;
//	}
//	
//	self.backgroundColor = self.previousBackgroundColor;
//	
//	return [super endTrackingWithTouch:touch withEvent:event];
//}
//
//- (void)cancelTrackingWithEvent:(UIEvent *)event
//{
//	if (_showingTextLabel) {
//		self.showingTextLabel.highlighted = FALSE;
//	}
//	
//	if (_moreTextLabel) {
//		self.moreTextLabel.highlighted = FALSE;
//	}
//	
//	self.backgroundColor = self.previousBackgroundColor;
//	
//	return [super cancelTrackingWithEvent:event];
//}

#pragma mark -
#pragma mark Highlighted:

- (void)setHighlighted:(BOOL)highlighted
{
	[super setHighlighted:highlighted];
	
	if (_showingTextLabel) {
		self.showingTextLabel.highlighted = [self isHighlighted];
	}
	
	if (_moreTextLabel) {
		self.moreTextLabel.highlighted = [self isHighlighted];
	}
	
	[self setNeedsDisplay];
}

#pragma mark -
#pragma mark Draw

- (void)drawRect:(CGRect)rect
{
	if ([self isHighlighted]) {
		// Stick a background gradient when highlighted
		CGContextRef ctx = UIGraphicsGetCurrentContext();
		
		CGContextSaveGState(ctx);
		
		CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
		CGFloat components[] = {5.0/255.0, 140.0/255.0, 245.0/255.0, 1.0, 1.0/255.0, 92.7/255.0, 230.0/255.0, 1.0};
		CGFloat locations[] = {0.0, 1.0};
		CGGradientRef gradient = CGGradientCreateWithColorComponents(space, components, locations, 2);
		CGContextDrawLinearGradient(ctx, gradient, CGPointMake(rect.origin.x, rect.origin.y),
									CGPointMake(rect.origin.x, rect.size.height), kCGGradientDrawsAfterEndLocation);
		CGGradientRelease(gradient);
		CGColorSpaceRelease(space);
		
		CGContextRestoreGState(ctx);
	}
	
	// Draw the rest
	[super drawRect:rect];
}


- (void)dealloc {
	
    [_backgroundImage release];
	[_selectedBackgroundImage release];
	[_previousBackgroundColor release];
	[_activityIndicatorView release];
	[_showingTextLabel release];
	[_moreTextLabel release];
	[_backgroundImageView release];
	
	[super dealloc];
}


@end
