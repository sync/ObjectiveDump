//
//  BasePinAnnotation.m
//  ObjectiveDump
//
//  Created by Anthony Mittaz on on 25/08/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import "BasePinAnnotation.h"


@implementation BasePinAnnotation

@synthesize objectID=_objectID;
@synthesize coordinate=_coordinate;
@synthesize title=_title;
@synthesize subtitle=_subtitle;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate
{
	if ([self init]) {
		self.coordinate = coordinate;
		self.title = nil;
		self.objectID = nil;
	}
	return self;
}

- (void)dealloc
{
	[_subtitle release];
	[_title release];
	[_objectID release];
	
	[super dealloc];
}

@end
