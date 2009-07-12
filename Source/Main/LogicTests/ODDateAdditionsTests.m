//
//  ODDateAdditionsTests.m
//  ObjectiveDump
//
//  Created by Anthony Mittaz on 12/07/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import "ODDateAdditionsTests.h"
#import "ODDateAdditions.h"

@implementation ODDateAdditionsTests

- (void)testDateIsEarlier
{
    
	NSDate *todayDate = [NSDate date];
	NSDate *laterDate = [todayDate addTimeInterval:500.0];

	STAssertTrue([todayDate isEarlierThanDate:laterDate], @"Today's date is not earlier than later today's date.");
    
}

- (void)testDateIsEarlierIfDateIsNil
{
    
	NSDate *date = nil;
	NSDate *laterDate = [[NSDate date] addTimeInterval:500.0];
	
	STAssertFalse([date isEarlierThanDate:laterDate], @"Today's date if nil is not earlier than later today's date.");
    
}

- (void)testDateIsLater
{
    
	NSDate *todayDate = [NSDate date];
	NSDate *laterDate = [todayDate addTimeInterval:500.0];
	
	STAssertTrue([laterDate isLaterThanDate:todayDate], @"Later today's date is not later than today's date.");
    
}

- (void)testDateIsLaterIfDateIsNil
{
    
	NSDate *todayDate = nil;
	NSDate *laterDate = [[NSDate date] addTimeInterval:500.0];
	
	STAssertFalse([laterDate isLaterThanDate:todayDate], @"Later today's date is not later than today's date.");
    
}


@end
