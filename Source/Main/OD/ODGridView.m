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
#pragma mark Reloading

- (void)reloadData
{
	// Remove all previous item
	// recycle all tiles so that every tile will be replaced in the next layoutSubviews
    for (UIView *view in self.currentItems) {
        [self.reusableItems addObject:view];
        [view removeFromSuperview];
    }
	
//	// Asks delegate for number of items
//	NSInteger nbrOfItems = 0;
//	if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfItemsInGridView:)]) {
//		nbrOfItems = [self.dataSource numberOfItemsInGridView:self];
//	}
//	// Loop trough each items and add them
//	if (nbrOfItems > 0) {
//		NSInteger horizontalDiff = (self.bounds.size.width - self.numberOfColumns * self.gridItemSize.width) / (self.numberOfColumns + 1);
//		if (self.horizontalOffset < 0) {
//			horizontalDiff = self.horizontalOffset;
//		}
//		
//		NSInteger height = 0;
//		
//		for (NSInteger i = 0; i < nbrOfItems; i++) {
//			// calculate the frame
//			// Get the row
//			NSInteger row = (i==0) ? 0 : i / self.numberOfColumns;
//			// Get the columng
//			NSInteger column = (i==0) ? 0 : i % self.numberOfColumns;
//			// Bild the frame
//			CGRect frame = CGRectMake(horizontalDiff * (column + 1) + column * self.gridItemSize.width, 
//									  self.verticalOffset * (row + 1)  + row * self.gridItemSize.height, 
//									  self.gridItemSize.width, 
//									  self.gridItemSize.height);
//			if (self.delegate && [self.delegate respondsToSelector:@selector(gridView:itemForIndex:)]) {
//				ODGridItemView *gridItemView = [self itemForIndex:i];
//				if (gridItemView) {
//					gridItemView.frame = frame;
//					gridItemView.delegate = self;
//					gridItemView.index = i;
//					[self addSubview:gridItemView];
//				}
//			}
//			
//			height = frame.origin.y + frame.size.height + self.verticalOffset;
//		}
//		
//		self.contentSize = CGSizeMake(self.bounds.size.width, height);
//	}
	
	[self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
	
	// Get all current subviews
	// See if they still have to be displayed
	// If not remove them
	CGRect visibleBounds = [self bounds];
	DLog(@"visibleBounds %@", NSStringFromCGRect(visibleBounds));
	// Here we can check the height of the entire scroll view
	CGSize contentSize = self.contentSize;
	DLog(@"contentSize %@", NSStringFromCGSize(contentSize));
	
	for (UIView *item in self.currentItems) {
		// We want to see if the tiles intersect our (i.e. the scrollView's) bounds, so we need to convert their
        // frames to our own coordinate system
        CGRect scaledTileFrame = [self convertRect:[item frame] toView:self];
		
        // If the tile doesn't intersect, it's not visible, so we can recycle it
        if (! CGRectIntersectsRect(scaledTileFrame, visibleBounds)) {
            [self.reusableItems addObject:item];
            [item removeFromSuperview];
        }
	}
	
	// Asks delegate for number of items
	NSInteger nbrOfItems = 0;
	if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfItemsInGridView:)]) {
		nbrOfItems = [self.dataSource numberOfItemsInGridView:self];
	}
	
	// Calculate the content size
	if (nbrOfItems > 0) {
		// calculate the frame
		// Get the row
		NSInteger row = (nbrOfItems==0) ? 0 : nbrOfItems / self.numberOfColumns;
		CGFloat height =  self.verticalOffset * (row + nbrOfItems)  + row * self.gridItemSize.height + self.gridItemSize.height + self.verticalOffset;
		if (height < visibleBounds.size.height) {
			height = visibleBounds.size.height;
		}
		self.contentSize = CGSizeMake(visibleBounds.size.width, height);
	} else {
		self.contentSize =  CGSizeMake(visibleBounds.size.width, visibleBounds.size.height);
	}
	
	// Just do the maths if at least one item
	if (nbrOfItems > 0) {
		
	}
	
    CGFloat itemHeight = self.verticalOffset + [self gridItemSize].height;
	NSInteger maxRow = floorf(self.frame.size.height / itemHeight); // this is the maximum possible row
    NSInteger firstNeededRow = MAX(0, floorf(visibleBounds.origin.y / itemHeight));
    NSInteger lastNeededRow  = MIN(maxRow, floorf(CGRectGetMaxY(visibleBounds) / itemHeight));
	
	DLog(@"firstNeededRow %d", firstNeededRow);
	DLog(@"lastNeededRow %d", lastNeededRow);
	
	// iterate through needed rows and columns, adding any tiles that are missing
	NSInteger i = 0;
    for (NSInteger row = firstNeededRow; row <= lastNeededRow; row++) {
		if (self.delegate && [self.delegate respondsToSelector:@selector(gridView:itemForIndex:)]) {
//			NSInteger horizontalDiff = (self.bounds.size.width - self.numberOfColumns * self.gridItemSize.width) / (self.numberOfColumns + 1);
//			if (self.horizontalOffset < 0) {
//				horizontalDiff = self.horizontalOffset;
//			}
//			
//			
//			CGRect frame = CGRectMake(horizontalDiff * (column + 1) + column * self.gridItemSize.width, 
//									  self.verticalOffset * (row + 1)  + row * self.gridItemSize.height, 
//									  self.gridItemSize.width, 
//									  self.gridItemSize.height);
//			
//			
//			ODGridItemView *gridItemView = [self itemForIndex:i];
//			if (gridItemView) {
//				gridItemView.frame = frame;
//				gridItemView.delegate = self;
//				gridItemView.index = i;
//				[self addSubview:gridItemView];
//			}
			
		}
		i++;
    }
	
}

- (ODGridItemView *)itemForIndex:(NSInteger)index
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"index == %d", index];
	NSArray *cached = [self.currentItems filteredArrayUsingPredicate:predicate];
	
	ODGridItemView *gridItemView = nil;
	
	if (cached.count == 1) {
		gridItemView = [cached objectAtIndex:0];
	} else {
		gridItemView = [self.dataSource gridView:self itemForIndex:index];
	}
	
	return gridItemView;
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
		[self.delegate gridView:self didSelectItemAtIndex:view.tag];
	}
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
