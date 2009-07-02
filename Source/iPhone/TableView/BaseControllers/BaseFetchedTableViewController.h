//
//  BaseFetchedTableViewController.h
//  
//
//  Created by Anthony Mittaz on 19/03/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewController.h"

@interface BaseFetchedTableViewController : BaseTableViewController <NSFetchedResultsControllerDelegate>{
	NSFetchedResultsController *fetchedResultsController;
	
	NSString *_entityName;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, readonly) NSString *entityName;

// Merge any saved changes with the context on other thread
- (void)contextDidSave:(NSNotification *)notification;

@end
