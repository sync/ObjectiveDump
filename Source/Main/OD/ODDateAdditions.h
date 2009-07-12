//
//  ODDateAdditions.h
//  ObjectiveDump
//
//  Created by Anthony Mittaz on 12/07/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (RFC2822)

- (BOOL)isEarlierThanDate:(NSDate *)date;
- (BOOL)isLaterThanDate:(NSDate *)date;

@end
