//
//  GloballyUniquePathStringAdditions.h
//  
//
//  Created by Anthony Mittaz on 30/06/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (GloballyUniquePathStringAdditions)

+ (NSString *)globallyUniquePath;
+ (NSString *)applicationDocumentsDirectory ;

@end
