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
	
	// Reusable gid Item Views
	NSMutableSet *_reusableItems;
	NSArray *_currentItems;
	NSInteger _firstNeededRow;
	NSInteger _lastNeededRow;
	
	NSInteger _selectedItemIndex;
	CGFloat _itemSizeHeight;
}

@property (readwrite, nonatomic, assign) id <ODGridViewDelegate, UIScrollViewDelegate> delegate;
@property (readwrite, nonatomic, assign) id <ODGridViewDataSource> dataSource;

@property (nonatomic) CGSize gridItemSize;
@property (nonatomic) CGFloat horizontalOffset;
@property (nonatomic) CGFloat verticalOffset;
@property (nonatomic) NSInteger numberOfColumns;
@property (nonatomic, readonly) NSMutableSet *reusableItems;
@property (nonatomic, readonly) NSArray *currentItems;
@property (nonatomic) NSInteger firstNeededRow;
@property (nonatomic) NSInteger lastNeededRow;
@property (nonatomic, readonly) CGFloat itemSizeHeight;
@property (nonatomic) NSInteger selectedItemIndex;
@property (nonatomic, readonly) NSInteger itemsCount;

- (void)setupCustomInitialisation;

- (void)recycleViews;

- (void)reloadData;
- (ODGridItemView *)itemForIndex:(NSInteger)index;
- (ODGridItemView *)dequeueReusableItem;
- (void)deselectItemAtIndex:(NSInteger)index;

@end
									   
@protocol ODGridViewDelegate <NSObject>

- (void)gridView:(ODGridView *)gridView didSelectItemAtIndex:(NSInteger)index;
- (void)gridViewDidFinishLoading:(ODGridView *)gridView;

@end

@protocol ODGridViewDataSource <NSObject>

- (NSInteger)numberOfItemsInGridView:(ODGridView *)gridView;
- (ODGridItemView *)gridView:(ODGridView *)gridView itemForIndex:(NSInteger)index;

@end
