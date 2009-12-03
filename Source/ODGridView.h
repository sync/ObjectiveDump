//
//  ODGridView.h
//  ObjectiveDump
//
//  Created by Anthony Mittaz on 3/12/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ODTapDetectingView.h"
#import "ODGridItemView.h"

@protocol ODGridViewDelegate;
@protocol ODGridViewDataSource;

@interface ODGridView : UIScrollView <UIScrollViewDelegate, ODTapDetectingViewDelegate> {
	
	CGSize _gridItemSize;
	CGFloat _horizontalOffset;
	CGFloat _verticalOffset;
	NSInteger _numberOfColumns;
	
	id <ODGridViewDataSource>  _dataSource;
	
	// Chached Grid Item Views
	NSMutableArray *_cachedGridItems;
}

@property (readwrite, nonatomic, assign) id <ODGridViewDelegate, UIScrollViewDelegate> delegate;
@property (readwrite, nonatomic, assign) id <ODGridViewDataSource> dataSource;

@property (nonatomic, readonly) CGSize gridItemSize;
@property (nonatomic, readonly) CGFloat horizontalOffset;
@property (nonatomic, readonly) CGFloat verticalOffset;
@property (nonatomic, readonly) NSInteger numberOfColumns;

- (void)setupCustomInitialisation;

- (void)reloadData;
- (ODGridItemView *)itemForIndex:(NSInteger)index;

@end
									   
@protocol ODGridViewDelegate <NSObject>

- (void)gridView:(ODGridView *)gridView didSelectItemAtIndex:(NSInteger)index;

@end

@protocol ODGridViewDataSource <NSObject>

- (NSInteger)numberOfItemsInGridView:(ODGridView *)gridView;
- (ODGridItemView *)gridView:(ODGridView *)gridView itemForIndex:(NSInteger)index;

@end
