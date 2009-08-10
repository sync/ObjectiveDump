//
//  ODDateAdditions.m
//  ObjectiveDump
//
//  Created by Anthony Mittaz on 12/07/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import "ODDateAdditions.h"

@implementation NSDate (ODDateAdditions)

- (BOOL)isEarlierThanDate:(NSDate *)date
{
	NSTimeInterval timeIntervalDifference = [self timeIntervalSinceDate:date];
	if (timeIntervalDifference <= 0) {
		return TRUE;
	}
	return FALSE;
}

- (BOOL)isLaterThanDate:(NSDate *)date
{
	NSTimeInterval timeIntervalDifference = [self timeIntervalSinceDate:date];
	if (timeIntervalDifference > 0) {
		return TRUE;
	}
	return FALSE;
}

@end

