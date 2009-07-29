//
//  ODShowMoreCell.h
//  ObjectiveDump
//
//  Created by Anthony Mittaz on 29/07/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ODShowMoreCell : UITableViewCell {
	UILabel *_moreTextLabel;
	UILabel *_showingTextLabel;
	UIActivityIndicatorView *_activityIndicatorView;
}

@property (nonatomic, readonly) UILabel *moreTextLabel;
@property (nonatomic, readonly) UILabel *showingTextLabel;
@property (nonatomic, readonly) UIActivityIndicatorView *activityIndicatorView;

@end
