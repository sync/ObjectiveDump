//
//  BasePinAnnotation.h
//  ObjectiveDump
//
//  Created by Anthony Mittaz on 25/08/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>

@interface BasePinAnnotation : NSObject <MKAnnotation>{
	NSManagedObjectID *_objectID;
	
	CLLocationCoordinate2D _coordinate;
	
	NSString *_title;
	NSString *_subtitle;
}

@property (nonatomic, retain) NSManagedObjectID *objectID;
@property (nonatomic) CLLocationCoordinate2D coordinate;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

@end
