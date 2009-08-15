//
//  ODDataAdditions.h
//  ObjectiveDump
//
//  Created by Anthony Mittaz on 13/08/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//
//  Found here, thanks cocoadev
//  http://www.cocoadev.com/index.pl?NSDataCategory
//

#import <Foundation/Foundation.h>


@interface NSData (ODDataAdditions)

// ZLIB
- (NSData *) zlibInflate;
- (NSData *) zlibDeflate;

// GZIP
- (NSData *) gzipInflate;
- (NSData *) gzipDeflate;

@end
