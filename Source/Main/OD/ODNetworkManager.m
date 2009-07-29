//
//  ODNetworkManager.m
//  ObjectiveDump
//
//  Created by Anthony Mittaz on 29/07/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import "ODNetworkManager.h"

static ODNetworkManager *sharedODNetworkManager = nil;

@implementation ODNetworkManager

@synthesize remoteHostStatus;
@synthesize internetConnectionStatus;
@synthesize localWiFiConnectionStatus;
@synthesize hasValidNetworkConnection=_hasValidNetworkConnection;
@synthesize noConnectionAlertShowing=_noConnectionAlertShowing;

+ (ODNetworkManager*)sharedODNetworkManager
{
    @synchronized(self) {
        if (sharedODNetworkManager == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return sharedODNetworkManager;
}

#pragma mark -
#pragma mark Init

- (id)init
{
	self = [super init];
	if (self != nil) {
		/*
		 You can use the Reachability class to check the reachability of a remote host
		 by specifying either the host's DNS name (www.apple.com) or by IP address.
		 */
		self.hasValidNetworkConnection = FALSE;
		self.noConnectionAlertShowing = FALSE;
		
		[[ODReachability sharedReachability] setHostName:[self hostName]];
		[[ODReachability sharedReachability] setNetworkStatusNotificationsEnabled:YES];
		[self updateStatus];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kNetworkReachabilityChangedNotification object:nil];
	}
	return self;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedODNetworkManager == nil) {
            sharedODNetworkManager = [super allocWithZone:zone];
			// 
            return sharedODNetworkManager;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (unsigned)retainCount
{
    return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

#pragma mark -
#pragma mark Reachability

- (void)reachabilityChanged:(NSNotification *)note
{
    [self updateStatus];
}

- (void)updateStatus
{
	// Query the SystemConfiguration framework for the state of the device's network connections.
	self.remoteHostStatus           = [[ODReachability sharedReachability] remoteHostStatus];
	self.internetConnectionStatus	= [[ODReachability sharedReachability] internetConnectionStatus];
	self.localWiFiConnectionStatus	= [[ODReachability sharedReachability] localWiFiConnectionStatus];
	
	if ((self.remoteHostStatus == ODReachableViaWiFiNetwork) || (self.remoteHostStatus == ODReachableViaCarrierDataNetwork))  {
		self.hasValidNetworkConnection = TRUE;
	} else {
		self.hasValidNetworkConnection = FALSE;
	}
	
	
}

- (BOOL)isCarrierDataNetworkActive
{
	return (self.remoteHostStatus == ODReachableViaCarrierDataNetwork);
}

- (NSString *)hostName
{
	// Don't include a scheme. 'http://' will break the reachability checking.
	// Change this value to test the reachability of a different host.
	return @"www.google.com";
}

#pragma mark -
#pragma mark Alert No Netork Connection

- (void)alertNoNetworkConnection
{
	if (!self.noConnectionAlertShowing) {
		// open an alert with just an OK button
		self.noConnectionAlertShowing = TRUE;
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Unable to load as you do not have an Internet connection."
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];	
		[alert release];
	}	
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	self.noConnectionAlertShowing = FALSE;
	// the user clicked one of the OK/Cancel buttons
	if (buttonIndex == 0)
	{
		DLog(@"OK");
		// Do nothing
	}
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter]removeObserver:self];
	
	[super dealloc];
}

@end
