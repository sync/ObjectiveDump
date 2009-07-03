//
//  Base64.h
//  
//
//  Created by Anthony Mittaz on 21/01/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (MBBase64)

+ (id)dataWithBase64EncodedString:(NSString *)string;     //  Padding '=' characters are optional. Whitespace is ignored.
- (NSString *)base64Encoding;

@end
