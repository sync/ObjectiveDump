//
//  ODGridItemView.m
//  ObjectiveDump
//
//  Created by Anthony Mittaz on 2/12/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import "ODGridItemView.h"

#define NameLabelFontSize 14.0
#define DOUBLE_TAP_DELAY 0.35

@implementation ODGridItemView

@synthesize index=_index;
@synthesize style=_style;
@synthesize selected=_selected;
@synthesize selectedView=_selectedView;

// The designated initializer. Override to perform setup that is required before the view is loaded.
// Only when xibless (interface buildder)
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Custom initialization
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
	self.backgroundColor = [UIColor clearColor];
	// Selected view
	UIView *selectedView = [[UIView alloc]initWithFrame:CGRectZero];
	selectedView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.5];
	self.selectedView = selectedView;
	[selectedView release];
}

+ (id)gridItemWithStyle:(ODGridItemViewStyle)style
{
	ODGridItemView *item = [[[ODGridItemView alloc]initWithFrame:CGRectZero]autorelease];
	item.style = style;
	
	if (style == ODGridItemViewStyleBordered ) {
		CALayer *layer = [item layer];
		[layer setBorderWidth:1.0];
		[layer setBorderColor:[[UIColor colorWithRed:103.0/255.0 green:101.0/255.0 blue:102.0/255.0 alpha:1.0] CGColor]];
	}
	
	
	return item;
}

- (UILabel *)nameLabel
{
	if (!_nameLabel) {
		_nameLabel = [[UILabel alloc]initWithFrame:CGRectZero];
		_nameLabel.font = [UIFont boldSystemFontOfSize:NameLabelFontSize];
		_nameLabel.textColor = [UIColor blackColor];
		_nameLabel.highlightedTextColor = [UIColor whiteColor];
		_nameLabel.numberOfLines = 0;
		_nameLabel.textAlignment = UITextAlignmentCenter;
		_nameLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:_nameLabel];
	}
	return _nameLabel;
}

- (UIImageView *)imageView
{
	if (!_imageView) {
		_imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
		_imageView.contentMode = UIViewContentModeScaleAspectFit;
		[self addSubview:_imageView];
	}
	return _imageView;
}

#pragma mark -
#pragma mark Layout

- (void)layoutSubviews
{
	[super layoutSubviews];
	
#define ImageLabelDiff 5.0
	
	// Get the frame where you can place your subviews
	CGRect rect = self.bounds;
	
	UIImage *image = self.imageView.image;
	
	NSInteger difference = (self.bounds.size.width - image.size.width) / 2;
	
	// Place the image view
	if (_imageView) {
		self.imageView.frame = CGRectIntegral(CGRectMake(rect.origin.x + difference, 
														 rect.origin.y + difference, 
														 image.size.width, 
														 image.size.height));
	}
	
	if (_nameLabel && self.style == ODGridItemViewStyleTitle) {
		self.nameLabel.frame = CGRectIntegral(CGRectMake(rect.origin.x + difference, 
														 rect.origin.y + difference  + image.size.height + ImageLabelDiff, 
														 image.size.width, 
														 (NameLabelFontSize + 4.0) * 2.0));
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
	// is selected
	self.selectedView.frame = self.bounds;
	[self insertSubview:self.selectedView aboveSubview:self.imageView];
	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	tapLocation = [touch locationInView:self];
	
	[self performSelector:@selector(handleSingleTap) withObject:nil afterDelay:DOUBLE_TAP_DELAY];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesCancelled:touches withEvent:event];
	// selection canceled
	[self.selectedView removeFromSuperview];
}


- (void)setSelected:(BOOL)selected
{
	if (_selected != selected) {
		_selected = selected;
	}
	
	if (!selected) {
		[self.selectedView removeFromSuperview];
	}
}


- (void)dealloc {
	[_imageView release];
	[_nameLabel release];
	
    [super dealloc];
}

@end
