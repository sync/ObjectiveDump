//
//  MyLocationGetter.h
//  
//
//  Created by Anthony Mittaz on 29/06/08.
//  Copyright 2008 Anthony Mittaz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

// GPS
#define ShouldStopGPSLocationFix @"ShouldStopGPSLocationFix"
#define GPSLocationDidFix @"GPSLocationDidFix"

@interface MyLocationGetter : NSObject <CLLocationManagerDelegate> {
	
	CLLocationManager *locationManager;

}

- (void)startUpdates;

@property (nonatomic, retain) CLLocationManager *locationManager;

@end
