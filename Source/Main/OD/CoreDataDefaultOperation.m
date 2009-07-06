//
//  CoreDataDefaultOperation.m
//  ObjectiveDump
//
//  Created by Anthony Mittaz on 2/07/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import "CoreDataDefaultOperation.h"


@implementation CoreDataDefaultOperation

@synthesize databaseName=_databaseName;
@synthesize managedObjectID=_managedObjectID;

- (void)main
{
	if ([self isCancelled])
	{
		return;  // user cancelled this operation
	}
	
	
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


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", self.databaseName]]];
	
	NSError *error;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
        // Handle error
    }    
	
    return persistentStoreCoordinator;
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
	
	[_managedObjectID release];
	[_databaseName release];
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];

	[super dealloc];
}


@end
