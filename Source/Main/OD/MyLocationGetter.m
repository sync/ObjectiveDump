//
//  MyLocationGetter.m
//  
//
//  Created by Anthony Mittaz on 29/06/08.
//  Copyright 2008 Anthony Mittaz. All rights reserved.
//

#import "MyLocationGetter.h"


@implementation MyLocationGetter

@synthesize locationManager;

- (void)startUpdates
{
    // Create the location manager if this object does not
    // already have one.
    if (nil == locationManager)
        locationManager = [[CLLocationManager alloc] init];
	
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
	
    // Set a movement threshold for new events
    locationManager.distanceFilter = 500;
	
    [locationManager startUpdatingLocation];
}

- (void)stopUpdates
{	
    [locationManager stopUpdatingLocation];
}


// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
    // If it's a relatively recent event, turn off updates to save power
    NSDate* eventDate = newLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 5.0)
    {
        [manager stopUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	if ([error code] == kCLErrorDenied) {
		// should stop looking for coordinates
		[self.locationManager stopUpdatingLocation];
		[[NSNotificationCenter defaultCenter] postNotificationName:ShouldStopGPSLocationFix object:nil userInfo:nil];
	}
}

- (void)dealloc {
	[locationManager release];
	
	[super dealloc];
}

@end
