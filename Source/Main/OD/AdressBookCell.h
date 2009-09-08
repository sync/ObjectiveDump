//
//  AdressBookCell.h
//  ObjectiveDump
//
//  Created by Anthony Mittaz on 27/09/08.
//  Copyright 2008 Anthony Mittaz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AdressBookCell : UITableViewCell {
	BOOL _highlighted;
	
	UILabel *_titleLabel;
	UILabel *_detailsLabel;
}

@property (nonatomic, getter=isHighlighted) BOOL highlighted;

@property (nonatomic, readonly) UILabel *titleLabel;
@property (nonatomic, readonly) UILabel *detailsLabel;


// Compute Height
+ (CGFloat)cellHeightWithText:(NSString *)text minCellHeight:(CGFloat)minHeight forTableViewWidth:(CGFloat)tableViewWidth;

@end
