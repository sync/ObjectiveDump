//
//  ODImageAdditions.h
//  ObjectiveDump
//
//  Created by Anthony Mittaz on 7/12/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIImage (ODImageAdditions)

- (NSString *)writeToDocumentsAtomically:(BOOL)flag;

@end
