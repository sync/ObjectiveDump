//
//  ODGridItemView.h
//  ObjectiveDump
//
//  Created by Anthony Mittaz on 2/12/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ODTapDetectingView.h"

@interface ODGridItemView : ODTapDetectingView {
	
	UIImageView *_imageView;
	UILabel *_nameLabel;
	
	UIImage *_selectedImage;
	UIImage *_image;
	
	NSInteger _index;
}

@property (nonatomic, readonly) UIImageView *imageView;
@property (nonatomic, readonly) UILabel *nameLabel;
@property (nonatomic, retain) UIImage *selectedImage;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic) NSInteger index;

- (void)setupCustomInitialisation;

+ (id)gridItem;


@end
