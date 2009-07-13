//
//  GloballyUniquePathStringAdditions.m
//  ObjectiveDump
//
//  Created by Anthony Mittaz on 30/06/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import "GloballyUniquePathStringAdditions.h"


@implementation NSString (GloballyUniquePathStringAdditions)

+ (NSString *)globallyUniquePath
{
	//Build the path we want the file to be at 
	NSString *basePath = [self applicationDocumentsDirectory];
	NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString]; 
	return [basePath stringByAppendingPathComponent:guid];
}

#pragma mark -
#pragma mark Application's documents directory

/**
 Returns the path to the application's documents directory.
 */

+ (NSString *)applicationDocumentsDirectory 
{
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

@end
