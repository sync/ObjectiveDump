//
//  AdressBookCell.m
//  ObjectiveDump
//
//  Created by Anthony Mittaz on 27/09/08.
//  Copyright 2008 Anthony Mittaz. All rights reserved.
//

#import "AdressBookCell.h"

@implementation AdressBookCell

@synthesize highlighted=_highlighted;
@synthesize titleLabel=_titleLabel;
@synthesize detailsLabel=_detailsLabel;

#define TitleFontSize 13.0
#define DetailsFontSize 13.0
#define DefaultRowHeight 56.0
#define FontLabelDiff 4.0
#define TitleDetailHorizontalOffset 10.0
#define TitleWidth 90.0
#define HorizontalOffset 10.0
#define VerticalOffset 3.0

#pragma mark -
#pragma mark Initialisation:

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		// Initialization code
	}
	return self;
}

- (UILabel *)titleLabel
{
	if (!_titleLabel) {
		_titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
		_titleLabel.font = [UIFont boldSystemFontOfSize:TitleFontSize];
		_titleLabel.textColor = [UIColor blackColor];
		_titleLabel.highlightedTextColor = [UIColor whiteColor];
		_titleLabel.textAlignment = UITextAlignmentRight;
		_titleLabel.baselineAdjustment = UIBaselineAdjustmentNone;
		[self.contentView addSubview:_titleLabel];
	}
	return _titleLabel;
}

- (UILabel *)detailsLabel
{
	if (!_detailsLabel) {
		_detailsLabel = [[UILabel alloc]initWithFrame:CGRectZero];
		_detailsLabel.font = [UIFont boldSystemFontOfSize:DetailsFontSize];
		_detailsLabel.textColor = [UIColor blackColor];
		_detailsLabel.highlightedTextColor = [UIColor whiteColor];
		_detailsLabel.numberOfLines = 0;
		_detailsLabel.textAlignment = UITextAlignmentLeft;
		_detailsLabel.baselineAdjustment = UIBaselineAdjustmentNone;
		[self.contentView addSubview:_detailsLabel];
	}
	return _detailsLabel;
}

#pragma mark -
#pragma mark Layout

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	// title to the left
	if (_titleLabel) {
		self.titleLabel.frame = CGRectMake(self.contentView.bounds.origin.x + HorizontalOffset, 
										   self.contentView.bounds.origin.y + roundf(self.contentView.bounds.origin.y + (DefaultRowHeight - TitleFontSize - FontLabelDiff) / 2.0),
										   TitleWidth, 
										   TitleFontSize + 2);
	}
	
	// details to the right
	if (_detailsLabel) {
		// Temporary fix
		self.detailsLabel.frame = CGRectMake(self.contentView.bounds.origin.x + HorizontalOffset + TitleDetailHorizontalOffset + TitleWidth, 
											 self.contentView.bounds.origin.y + roundf(self.contentView.bounds.origin.y + (DefaultRowHeight - TitleFontSize - FontLabelDiff) / 2.0), 
											 self.contentView.bounds.size.width - HorizontalOffset - TitleDetailHorizontalOffset - TitleWidth - HorizontalOffset, 
											 self.contentView.bounds.size.height - 2 * (self.contentView.bounds.origin.y + roundf(self.contentView.bounds.origin.y + (DefaultRowHeight - TitleFontSize - FontLabelDiff) / 2.0)));
		
	}
}

#pragma mark -
#pragma mark Reuse

- (void)prepareForReuse
{
	[super prepareForReuse];
	
	// Reset title text
	if (_titleLabel) {
		self.titleLabel.text = nil;
	}
	// Reset details text 
	if (_detailsLabel) {
		self.detailsLabel.text = nil;
	}
}

#pragma mark -
#pragma mark Allow The TableView To Draw Differently When Cell Is Being Edited:

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	[super setEditing:editing animated:animated];
}

#pragma mark -
#pragma mark Allow The TableView To Draw Differently When Cell Selected:

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	
	[super setSelected:selected animated:animated];
	
	// Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)lit {
	// If highlighted state changes, need to redisplay.
	if (_highlighted != lit) {
		_highlighted = lit;	
		[self setNeedsDisplay];
	}
}

#pragma mark -
#pragma mark Compute Height:

+ (CGFloat)cellHeightWithText:(NSString *)text minCellHeight:(CGFloat)minHeight forTableViewWidth:(CGFloat)tableViewWidth
{
	// Create the same label
	UILabel *detailsLabel = [[UILabel alloc]initWithFrame:CGRectZero];
	detailsLabel.font = [UIFont boldSystemFontOfSize:DetailsFontSize];
	detailsLabel.textColor = [UIColor blackColor];
	detailsLabel.highlightedTextColor = [UIColor whiteColor];
	detailsLabel.numberOfLines = 0;
	detailsLabel.textAlignment = UITextAlignmentLeft;
	// Set the fake label text
	detailsLabel.text = text;
	// Compute the bounds
	//self.contentView.bounds.size.width - HorizontalOffset - TitleDetailHorizontalOffset - TitleWidth - HorizontalOffset,
	CGRect newBounds = CGRectMake(0.0, 
								  0.0, 
								  tableViewWidth - HorizontalOffset - TitleDetailHorizontalOffset - TitleWidth - HorizontalOffset, 
								  2009.0);
	CGRect tempSizeRect = [detailsLabel textRectForBounds:newBounds limitedToNumberOfLines:0];
	
	CGFloat cellHeight = tempSizeRect.size.height;
	
	// Add the height difference
	cellHeight += 2 * (roundf((DefaultRowHeight - TitleFontSize - FontLabelDiff) / 2.0));
	
	if (cellHeight < minHeight) {
		cellHeight = minHeight;
	}
	
	[detailsLabel release];
	
	return cellHeight;
}

#pragma mark -
#pragma mark Dealloc:

- (void)dealloc {
	[_titleLabel release];
	[_detailsLabel release];    
	[super dealloc];
}


@end
