//
//  ODGridItemView.h
//  ObjectiveDump
//
//  Created by Anthony Mittaz on 2/12/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ODTapDetectingView.h"

typedef enum {
	ODGridItemViewStyleDefault,
	ODGridItemViewStyleBordered,
	ODGridItemViewStyleTitle
} ODGridItemViewStyle;

@interface ODGridItemView : ODTapDetectingView {
	
	UIImageView *_imageView;
	UILabel *_nameLabel;
	UIView *_selectedView;
	
	NSInteger _index;
	ODGridItemViewStyle _style;
	BOOL _selected;
}

@property (nonatomic, readonly) UIImageView *imageView;
@property (nonatomic, readonly) UILabel *nameLabel;
@property (nonatomic, retain) UIView *selectedView;
@property (nonatomic) NSInteger index;
@property (nonatomic) ODGridItemViewStyle style;
@property (nonatomic) BOOL selected;

- (void)setupCustomInitialisation;

+ (id)gridItemWithStyle:(ODGridItemViewStyle)style;


@end
