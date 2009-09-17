//
//  CoreDataDefaultOperation.h
//  ObjectiveDump
//
//  Created by Anthony Mittaz on 2/07/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DefaultOperation.h"

@interface CoreDataDefaultOperation : DefaultOperation {
	
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
	
	NSString *_databaseName;
	
	NSManagedObjectID *_managedObjectID;
	NSManagedObject *_object;
}

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) NSManagedObjectID *managedObjectID;
@property (nonatomic, readonly) NSManagedObject *object;

@property (nonatomic, readonly) NSString *applicationDocumentsDirectory;


// Context Did Save
- (void)contextDidSave:(NSNotification *)notification;

@end
