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
@synthesize cachedGridItems=_cachedGridItems;

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

- (NSMutableArray *)cachedGridItems
{
	if (!_cachedGridItems) {
		_cachedGridItems = [[NSMutableArray alloc]initWithCapacity:0];
	}
	
	return _cachedGridItems;
}

#pragma mark -
#pragma mark Reloading

- (void)reloadData
{
	// Remove all previous item
	for (id view in self.subviews) {
		[view removeFromSuperview];
	}
	// Asks delegate for number of items
	NSInteger nbrOfItems = 0;
	if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfItemsInGridView:)]) {
		nbrOfItems = [self.dataSource numberOfItemsInGridView:self];
	}
	// Loop trough each items and add them
	if (nbrOfItems > 0) {
		NSInteger horizontalDiff = (self.bounds.size.width - self.numberOfColumns * self.gridItemSize.width) / (self.numberOfColumns + 1);
		if (self.horizontalOffset < 0) {
			horizontalDiff = self.horizontalOffset;
		}
		
		NSInteger height = 0;
		
		for (NSInteger i = 0; i < nbrOfItems; i++) {
			// calculate the frame
			// Get the row
			NSInteger row = (i==0) ? 0 : i / self.numberOfColumns;
			// Get the columng
			NSInteger column = (i==0) ? 0 : i % self.numberOfColumns;
			// Bild the frame
			CGRect frame = CGRectMake(horizontalDiff * (column + 1) + column * self.gridItemSize.width, 
									  self.verticalOffset * (row + 1)  + row * self.gridItemSize.height, 
									  self.gridItemSize.width, 
									  self.gridItemSize.height);
			if (self.delegate && [self.delegate respondsToSelector:@selector(gridView:itemForIndex:)]) {
				ODGridItemView *gridItemView = [self.dataSource gridView:self itemForIndex:i];
				if (gridItemView) {
					gridItemView.frame = frame;
					gridItemView.delegate = self;
					gridItemView.index = i;
					[self addSubview:gridItemView];
					[self.cachedGridItems addObject:gridItemView];
				}
			}
			
			height = frame.origin.y + frame.size.height + self.verticalOffset;
		}
		
		self.contentSize = CGSizeMake(self.bounds.size.width, height);
	}
}

- (ODGridItemView *)itemForIndex:(NSInteger)index
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"index == %d", index];
	
	
	NSArray *cached = [self.cachedGridItems filteredArrayUsingPredicate:predicate];
	
	ODGridItemView *gridItemView = nil;
	
	if (cached.count == 1) {
		gridItemView = [cached objectAtIndex:0];
	}
	
	return gridItemView;
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
	
    [_cachedGridItems release];
	[super dealloc];
}


@end
