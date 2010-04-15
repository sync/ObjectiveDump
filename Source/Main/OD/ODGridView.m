//
//  ODGridView.m
//  ObjectiveDump
//
//  Created by Anthony Mittaz on 3/12/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import "ODGridView.h"

@implementation ODGridView

@synthesize dataSource=_dataSource;
@synthesize gridItemSize=_gridItemSize;
@synthesize numberOfColumns=_numberOfColumns;
@synthesize horizontalOffset=_horizontalOffset;
@synthesize verticalOffset=_verticalOffset;
@synthesize firstNeededRow=_firstNeededRow;
@synthesize lastNeededRow=_lastNeededRow;
@synthesize selectedItemIndex=_selectedItemIndex;

#pragma mark -
#pragma mark Overwrite delegate

- delegate {
	return [super delegate];
}

- (void)setDelegate:(id <ODGridViewDelegate, UIScrollViewDelegate>)d {
	[super setDelegate:d];
}

#pragma mark -
#pragma mark Initialization

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
	self.backgroundColor = [UIColor whiteColor];
	// Default values
	self.horizontalOffset = 10.0;
	self.verticalOffset = 10.0;
	self.gridItemSize = CGSizeMake(80.0, 80.0);
	self.numberOfColumns = 3;
	self.selectedItemIndex = -1;
}

- (NSMutableSet *)reusableItems
{
	if (!_reusableItems) {
		_reusableItems = [[NSMutableSet alloc]init];
	}
	
	return _reusableItems;
}

- (NSArray *)currentItems
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"class == %@", [ODGridItemView class]];
	NSArray *subviews = [self.subviews filteredArrayUsingPredicate:predicate];
	
	return subviews;
}

#pragma mark -
#pragma mark Item Size Height

- (CGFloat)itemSizeHeight
{	
	if (_itemSizeHeight <= 0.0) {
		ODGridItemView *gridItemView = [self itemForIndex:0];
		if (gridItemView) {
			_itemSizeHeight = (gridItemView.style == ODGridItemViewStyleTitle) ? self.gridItemSize.height + 40.0 : self.gridItemSize.height;
		} else if (self.currentItems.count > 0) {
			ODGridItemView *item = [self.currentItems objectAtIndex:0];
			_itemSizeHeight = (item.style == ODGridItemViewStyleTitle) ? self.gridItemSize.height + 40.0 : self.gridItemSize.height;
		} else {
			_itemSizeHeight = 0.0;
		}
	}
	
	
	return _itemSizeHeight;
}

#pragma mark -
#pragma mark Reloading

- (void)reloadData
{
	// Remove all previous item
	// recycle all tiles so that every tile will be replaced in the next layoutSubviews
    for (UIView *view in self.currentItems) {
        [self.reusableItems addObject:view];
        [view removeFromSuperview];
    }
	
	self.firstNeededRow = -1;
	self.lastNeededRow = -1;
	
	_itemSizeHeight = -1.0;
	
	[self setNeedsLayout];
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(gridViewDidFinishLoading:)]) {
		[self.delegate gridViewDidFinishLoading:self];
	}
}

- (void)recycleViews
{
	// Get all current subviews
	// See if they still have to be displayed
	// If not remove them
	CGRect visibleBounds = [self bounds];
	
	for (UIView *item in self.currentItems) {
		// We want to see if the tiles intersect our (i.e. the scrollView's) bounds, so we need to convert their
        // frames to our own coordinate system
        CGRect tileFrame = [self convertRect:[item frame] toView:self];
		CGRect modifiedFrame = CGRectMake(tileFrame.origin.x, tileFrame.origin.y - self.verticalOffset, tileFrame.size.width, tileFrame.size.height + self.verticalOffset);
		
        // If the tile doesn't intersect, it's not visible, so we can recycle it
        if (! CGRectIntersectsRect(modifiedFrame, visibleBounds)) {
            [self.reusableItems addObject:item];
            [item removeFromSuperview];
        }
	}
}

- (void)layoutSubviews {
    [super layoutSubviews];
	
	// Get all current subviews
	// See if they still have to be displayed
	// If not remove them
	CGRect visibleBounds = [self bounds];
	
	[self recycleViews];
	
	// Asks delegate for number of items
	NSInteger nbrOfItems = self.itemsCount;
	
	// Calculate the content size
	if (nbrOfItems > 0) {
		// calculate the frame
		// Get the row
		NSInteger row = ceilf((float)nbrOfItems / (float)self.numberOfColumns);
		CGFloat height =  row * (self.itemSizeHeight + self.verticalOffset);
		if (height < visibleBounds.size.height) {
			height = visibleBounds.size.height;
		}
		self.contentSize = CGSizeMake(visibleBounds.size.width, height);
	} else {
		self.contentSize =  CGSizeMake(visibleBounds.size.width, visibleBounds.size.height);
	}
	
	// Just do the maths if at least one item
	if (nbrOfItems > 0) {
		CGFloat itemHeight = self.verticalOffset + self.itemSizeHeight;
		NSInteger firstNeededRow = floorf(visibleBounds.origin.y / itemHeight);
		NSInteger lastNeededRow  = floorf((CGRectGetMaxY(visibleBounds)) / itemHeight);
		
		if (firstNeededRow < 0) {
			firstNeededRow = 0;
		}
		
		if (lastNeededRow > nbrOfItems / self.numberOfColumns) {
			lastNeededRow = nbrOfItems / self.numberOfColumns;
		}
		
		if (firstNeededRow == self.firstNeededRow && lastNeededRow == self.lastNeededRow) {
			return;
		}
		
		
		NSInteger firstNeededIndex = firstNeededRow * self.numberOfColumns;
		if (firstNeededIndex > nbrOfItems) {
			firstNeededIndex = nbrOfItems - 1;
		}
		NSInteger lastNeededIndex = lastNeededRow * self.numberOfColumns + self.numberOfColumns - 1;
		if (lastNeededIndex > nbrOfItems) {
			lastNeededIndex = nbrOfItems - 1;
		}
		
		NSInteger horizontalDiff = (self.bounds.size.width - self.numberOfColumns * self.gridItemSize.width) / (self.numberOfColumns + 1);
		if (self.horizontalOffset < 0) {
			horizontalDiff = self.horizontalOffset;
		}
		
		for (NSInteger i = firstNeededIndex; i <= lastNeededIndex; i++) {
			// calculate the frame
			// Get the row
			NSInteger row = (i==0) ? 0 : i / self.numberOfColumns;
			// Get the columng
			NSInteger column = (i==0) ? 0 : i % self.numberOfColumns;
			// Bild the frame
			CGRect frame = CGRectMake(horizontalDiff * (column + 1) + column * self.gridItemSize.width, 
									  self.verticalOffset * (row + 1)  + row * self.itemSizeHeight, 
									  self.gridItemSize.width, 
									  self.itemSizeHeight);
			
			ODGridItemView *gridItemView = [self itemForIndex:i];
			if (gridItemView) {
				gridItemView.frame = frame;
				gridItemView.delegate = self;
				gridItemView.index = i;
				gridItemView.selected = FALSE;
				[self addSubview:gridItemView];
			}
		}
		self.firstNeededRow = firstNeededRow;
		self.lastNeededRow = lastNeededRow;
	}
	
}

- (ODGridItemView *)itemForIndex:(NSInteger)index
{
	//DLog(@"GridView itemForIndex: %d", index);
	
	ODGridItemView *gridItemView = nil;
	
	if (!self.delegate || ![self.delegate respondsToSelector:@selector(gridView:itemForIndex:)]) {
		return gridItemView;
	}
	
	if (index >= self.itemsCount) {
		return gridItemView;
	}
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"index == %d", index];
	NSArray *cached = [self.currentItems filteredArrayUsingPredicate:predicate];
		
	if (cached.count == 1) {
		gridItemView = [cached objectAtIndex:0];
	} else {
		gridItemView = [self.dataSource gridView:self itemForIndex:index];
	}
	
	return gridItemView;
}

- (NSInteger)itemsCount
{
	NSInteger itemsCount = 0;
	if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfItemsInGridView:)]) {
		itemsCount = [self.dataSource numberOfItemsInGridView:self];
	}
	return itemsCount;
}

- (ODGridItemView *)dequeueReusableItem 
{
    ODGridItemView *item = (ODGridItemView *)[self.reusableItems anyObject];
    if (item) {
        // the only object retaining the tile is our reusableItems set, so we have to retain/autorelease it
        // before returning it so that it's not immediately deallocated when we remove it from the set
        [[item retain] autorelease];
        [self.reusableItems removeObject:item];
    }
    return item;
}

#pragma mark -
#pragma mark Tap DetectingView Delegate

- (void)tapDetectingView:(ODTapDetectingView *)view gotSingleTapAtPoint:(CGPoint)tapPoint
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(gridView:didSelectItemAtIndex:)]) {
		
		// Previous
		if (self.selectedItemIndex > 0) {
			[self deselectItemAtIndex:self.selectedItemIndex];
		}
		
		
		// Current
		ODGridItemView *item = (ODGridItemView *)view;
		item.selected = TRUE;
		self.selectedItemIndex = item.index;
		
		[self.delegate gridView:self didSelectItemAtIndex:item.index];
	}
}

- (void)deselectItemAtIndex:(NSInteger)index
{
	ODGridItemView *gridItemView = [self itemForIndex:index];
	gridItemView.selected = FALSE;
}


#pragma mark -
#pragma mark Drawing

- (void)drawRect:(CGRect)rect {
    // Nothing
}

#pragma mark -
#pragma mark Execut Method When Notification Fire

//help executing a method when a notification fire
- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object 
						change:(NSDictionary *)change 
					   context:(void *)context
{
	[self performSelector: (SEL)context withObject: change];
}


- (void)dealloc {
	
	[_currentItems release];
    [_reusableItems release];
	[super dealloc];
}


@end
