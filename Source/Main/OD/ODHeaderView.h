//
//  ODHeaderView.h
//  ObjectiveDump
//
//  Created by Anthony Mittaz on 7/07/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ODHeaderView : UIView {
	UIImageView *_backgroundView;
	UILabel *_titleLabel;
	
	CGFloat _leftRightOffset;
}

@property (nonatomic, readonly) UIImageView *backgroundView;
@property (nonatomic, readonly) UILabel *titleLabel;

@property (nonatomic) CGFloat leftRightOffset;

@end
