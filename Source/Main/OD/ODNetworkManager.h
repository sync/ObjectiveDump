//
//  ODNetworkManager.h
//  ObjectiveDump
//
//  Created by Anthony Mittaz on 29/07/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"


@class Reachability;

@interface ODNetworkManager : NSObject <UIAlertViewDelegate>{
	BOOL _hasValidNetworkConnection;
	BOOL _noConnectionAlertShowing;
	
	Reachability* hostReach;
}

// Access shared singleton
+ (ODNetworkManager *)sharedODNetworkManager;

// Network Connection Status
@property (nonatomic) BOOL hasValidNetworkConnection;

@property BOOL noConnectionAlertShowing;

// Network Connection
- (void)updateStatus;

- (void) reachabilityChanged: (NSNotification* )note;
- (void) updateInterfaceWithReachability: (Reachability*) curReach;

// Inform user when netowrk connection is not available
- (void)alertNoNetworkConnectionWithMessage:(NSString *)message;

@end
