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
		self.noConnectionAlertShowing = FALSE;
		self.hasValidNetworkConnection = FALSE;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
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

//Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )note
{
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	[self updateInterfaceWithReachability: curReach];
}

- (void) updateInterfaceWithReachability: (Reachability*) curReach
{
    if(curReach == hostReach)
	{
		NetworkStatus netStatus = [curReach currentReachabilityStatus];
		switch (netStatus)
		{
			case NotReachable:
			{
				self.hasValidNetworkConnection = FALSE;
			}
				
			case ReachableViaWWAN:
			{
				self.hasValidNetworkConnection = TRUE;
			}
			case ReachableViaWiFi:
			{
				self.hasValidNetworkConnection = TRUE;
			}
		}		
    }
	
}

- (void)updateStatus
{
	hostReach = [[Reachability reachabilityWithHostName: @"www.google.com"] retain];
	[hostReach startNotifer];
}

#pragma mark -
#pragma mark Alert No Netork Connection

- (void)alertNoNetworkConnectionWithMessage:(NSString *)message
{
	if (!message) {
		message = @"Unable to load as you do not have an Internet connection.";
	}
	if (!self.noConnectionAlertShowing) {
		// open an alert with just an OK button
		self.noConnectionAlertShowing = TRUE;
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message
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
