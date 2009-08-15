//
//  ODStringAdditions.m
//  ObjectiveDump
//
//  Created by Anthony Mittaz on 5/08/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ODStringAdditions.h"


@implementation NSString (ODStringAdditions)

// Get the element's initial letter
- (NSString *)firstIndex
{
	if (self.length == 0) {
		return nil;
	}
	NSString *string = [self substringToIndex:1];
	return string;
}

// Remove spaces and new line at the beginning and end of a strings
- (NSString *)trimNewLines
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
