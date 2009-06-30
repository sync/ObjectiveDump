//
//  BaseFetchedViewController.m
//  
//
//  Created by Anthony Mittaz on 14/04/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import "BaseFetchedViewController.h"


@implementation BaseFetchedViewController

@synthesize fetchedResultsController;
@synthesize tableView=_tableView;

- (void)viewDidLoad {
	[super viewDidLoad];
	
	NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		// Handle the error...
	}
}


- (void)viewDidUnload 
{	
	// Empty cell attributes array
	[_cellAttributes release];
	_cellAttributes = nil;
	
	// Empty cell key for attributes
	[_cellKeysForAttributes release];
	_cellKeysForAttributes = nil;
}

- (Class)cellClass
{
	return [UITableViewCell class];
}

- (UITableViewCellStyle)cellStyle
{
	return UITableViewCellStyleDefault;
}

- (NSArray *)cellAttributes
{
	if (!_cellAttributes) {
		_cellAttributes = [[NSArray alloc]init];
	}
	return _cellAttributes;
}

- (NSDictionary *)cellKeysForAttributes
{
	if (!_cellKeysForAttributes) {
		_cellKeysForAttributes = [[NSArray alloc]init];
	}
	return _cellKeysForAttributes;
}

- (NSString *)entityName
{
	if (!_entityName) {
		_entityName = [[NSString alloc]initWithFormat:@"Person"];
	}
	return _entityName;
}



/*
 - (void)viewWillAppear:(BOOL)animated {
 [super viewWillAppear:animated];
 }
 */
/*
 - (void)viewDidAppear:(BOOL)animated {
 [super viewDidAppear:animated];
 }
 */
/*
 - (void)viewWillDisappear:(BOOL)animated {
 [super viewWillDisappear:animated];
 }
 */
/*
 - (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }
 */

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[fetchedResultsController sections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(self.cellClass)];
    if (cell == nil) {
        cell = [[[self.cellClass alloc] initWithStyle:self.cellStyle reuseIdentifier:NSStringFromClass(self.cellClass)] autorelease];
    }
	
	id object = [self objectForIndexPath:indexPath];
    
	// Configure the cell.
	for (NSString *attribute in self.cellAttributes) {
		NSString *key = [self keyForAttribute:attribute];
		[cell setValue:[object valueForKey:key] forKey:attribute];
	}
	
    return cell;
}

- (NSString *)keyForAttribute:(NSString *)attribute
{
	return [self.cellKeysForAttributes valueForKey:attribute];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	// Use your object
	//	id object = [self objectForIndexPath:indexPath];
	
}

- (id)objectForIndexPath:(NSIndexPath *)indexPath
{
	return [self.fetchedResultsController objectAtIndexPath:indexPath];
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the managed object for the given index path
		NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
		[context deleteObject:[fetchedResultsController objectAtIndexPath:indexPath]];
		
		// Save the context.
		NSError *error;
		if (![context save:&error]) {
			// Handle the error...
		}
		
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}


/*
 // NSFetchedResultsControllerDelegate method to notify the delegate that all section and object changes have been processed. 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
 [self.tableView reloadData];
 }
 */


- (NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
    
    /*
	 Set up the fetched results controller.
	 */
	// Create the fetch request for the entity.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	// Edit the entity name as appropriate.
	NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:self.appDelegate.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	//	// Edit the sort key as appropriate.
	//	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"first_name" ascending:YES];
	//	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	//	
	//	[fetchRequest setSortDescriptors:sortDescriptors];
	
	// Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.appDelegate.managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
    aFetchedResultsController.delegate = self;
	self.fetchedResultsController = aFetchedResultsController;
	
	[aFetchedResultsController release];
	[fetchRequest release];
//	[sortDescriptor release];
//	[sortDescriptors release];
	
	return fetchedResultsController;
} 


- (void)dealloc {
	[_cellKeysForAttributes release];
	[_cellAttributes release];
	[_tableView release];
	[fetchedResultsController release];
	
    [super dealloc];
}


@end
