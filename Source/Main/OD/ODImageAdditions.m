//
//  ODImageAdditions.m
//  ObjectiveDump
//
//  Created by Anthony Mittaz on 7/12/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import "ODImageAdditions.h"
#import "GloballyUniquePathStringAdditions.h"

@implementation UIImage (ODImageAdditions)

- (NSString *)writeToDocumentsAtomically:(BOOL)flag
{
	NSData *imageData = UIImagePNGRepresentation(self);
	NSString *imagePath = nil;
	if (imageData && imageData.length > 0) {
		imagePath = [NSString stringWithFormat:@"%@.png", [NSString globallyUniquePath]];
		BOOL success = [imageData writeToFile:imagePath atomically:flag];
		if (!success) {
			DLog(@"could not write the file to path: %@", [imagePath lastPathComponent]);
		}
	}
	return [imagePath lastPathComponent];
}

@end
