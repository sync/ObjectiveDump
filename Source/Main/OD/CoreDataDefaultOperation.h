//
//  CoreDataDefaultOperation.h
//  ObjectiveDump
//
//  Created by Anthony Mittaz on 2/07/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DefaultOperation.h"

@interface CoreDataDefaultOperation : DefaultOperation {
	
	NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
	
	NSString *_databaseName;
}

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) NSString *databaseName;

@property (nonatomic, readonly) NSString *applicationDocumentsDirectory;

@end
