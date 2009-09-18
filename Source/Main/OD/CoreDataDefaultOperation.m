//
//  CoreDataDefaultOperation.m
//  ObjectiveDump
//
//  Created by Anthony Mittaz on 2/07/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import "CoreDataDefaultOperation.h"


@implementation CoreDataDefaultOperation

@synthesize persistentStoreCoordinator;
@synthesize managedObjectID=_managedObjectID;

- (void)main
{
	
	if ([self isCancelled])
	{
		return;  // user cancelled this operation
	}
	
	[self startOperation];
	
	NSData *responseData = [self downloadUrl];
	
	if (self.timedOut) {
		[self failOperationWithErrorString:@"TIMEOUT"];
	} else if ([responseData length] != 0)  {
        
		if (![self isCancelled])
		{
			
			[self finishOperationWithObject:responseData];
		}
	}
}

#pragma mark -
#pragma mark Core Data Helper

- (NSManagedObject *)object
{
	if (!_object) {
		_object = nil;
		if (self.managedObjectID) {
			_object = [self.managedObjectContext existingObjectWithID:self.managedObjectID error:nil];
		}
	}
	return _object;
}

#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}


#pragma mark -
#pragma mark Application's documents directory

/**
 Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	
	[[NSNotificationCenter defaultCenter]removeObserver:self];
	
	[_managedObjectID release];
	[_databaseName release];
    [managedObjectContext release];
    [persistentStoreCoordinator release];

	[super dealloc];
}


@end
