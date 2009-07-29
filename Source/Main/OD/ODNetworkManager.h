//
//  ODNetworkManager.h
//  ObjectiveDump
//
//  Created by Anthony Mittaz on 29/07/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ODReachability.h"

@interface ODNetworkManager : NSObject <UIAlertViewDelegate>{
	ODNetworkStatus remoteHostStatus;
	ODNetworkStatus internetConnectionStatus;
	ODNetworkStatus localWiFiConnectionStatus;
	
	BOOL _hasValidNetworkConnection;
	BOOL _noConnectionAlertShowing;
}

// Access shared singleton
+ (ODNetworkManager *)sharedODNetworkManager;

// Network Connection Status
@property (nonatomic) BOOL noConnectionAlertShowing;
@property (nonatomic) BOOL hasValidNetworkConnection;

@property (nonatomic) ODNetworkStatus remoteHostStatus;
@property (nonatomic) ODNetworkStatus internetConnectionStatus;
@property (nonatomic) ODNetworkStatus localWiFiConnectionStatus;

// Network Connection
- (void)updateStatus;
- (BOOL)isCarrierDataNetworkActive;
- (NSString *)hostName;

// Inform user when netowrk connection is not available
- (void)alertNoNetworkConnection;

@end
