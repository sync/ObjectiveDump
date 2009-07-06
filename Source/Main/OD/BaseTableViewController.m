//
//  BaseTableViewController.m
//  
//
//  Created by Anthony Mittaz on 5/02/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import "BaseTableViewController.h"
#import "GloballyUniquePathStringAdditions.h"

#define MyCellClass @"MyCellClass"

@implementation BaseTableViewController

@synthesize dumpedFilePath=_dumpedFilePath;
@synthesize dataSource=_dataSource;
@synthesize managedObjectContext=_managedObjectContext;
@synthesize object=_object;

#pragma mark -
#pragma mark Initialisation

// The designated initializer. Override to perform setup that is required before the view is loaded.
// Only when xibless (interface buildder)
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Custom initialization
		[self setupCustomInitialisation];
	}
	return self;
}

// The designated initializer. Override to perform setup that is required before the view is loaded.
// Only when using xib (interface buildder)
- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super initWithCoder:decoder]) {
		// Custom initialization
		[self setupCustomInitialisation];
	}
	return self;
}

- (void)setupCustomInitialisation
{
	// Nothing
}

#pragma mark -
#pragma mark View Events

- (void)viewDidLoad 
{
	[super viewDidLoad];
	
	// Set for example
	// Style and background color
	[self setupTableView];
	
	// Set for example
	// Color and items
	[self setupNavigationBar];
	
	// Set for example
	// Color and items 
	[self setupToolbar];
	
	// If using data source
	[self setupDataSource];
	
	// If using core data
	[self setupCoreData];
}

- (void)viewDidUnload 
{	
	// Dump array content to temporary file
	// Only if non nil and non empty
	if (self.content && [self.content count]>0) {
		self.dumpedFilePath = [NSString globallyUniquePath];
		[self.content writeToFile:self.dumpedFilePath atomically:FALSE];
	}
}

#pragma mark -
#pragma mark Setup

// Set for example
// Style and background color
- (void)setupTableView
{
	// Nothing
}

// Set for example
// Color and items
- (void)setupNavigationBar
{
	// Nothing
}

// Set for example
// Color and items 
- (void)setupToolbar
{	
	// Nothing
}

- (void)setupDataSource
{
	// Nothing
}

// Perform first fetch
// Reload tableview when context save
- (void)setupCoreData
{
	if (self.fetchedResultsController) {
		NSError *error;
		if (![self.fetchedResultsController performFetch:&error]) {
			// Handle the error...
		}
		
		// Merge any saved changes with the context on other thread
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(contextDidSave:) 
													 name:NSManagedObjectContextDidSaveNotification
												   object:nil];
	}
}

#pragma mark -
#pragma mark Context Did Save

- (void)contextDidSave:(NSNotification *)notification
{
	[self.fetchedResultsController.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark Subclassing

- (Class)cellClass
{
	if (self.dataSource) {
		return self.dataSource.cellClass;
	}
	return [UITableViewCell class];
}

- (UITableViewCellStyle)cellStyle
{
	if (self.dataSource) {
		return self.dataSource.cellStyle;
	}
	return UITableViewCellStyleDefault;
}

- (NSArray *)content
{
	if (self.dataSource) {
		return self.dataSource.content;
	}
	
	if (!_content) {
		if ([[NSFileManager defaultManager]fileExistsAtPath:self.dumpedFilePath]) {
			_content = [NSMutableArray arrayWithContentsOfFile:self.dumpedFilePath];
			[[NSFileManager defaultManager]removeItemAtPath:self.dumpedFilePath error:nil];
			self.dumpedFilePath = nil;
		} else {
			_content = [[NSMutableArray alloc]init];
		}
	}
	return _content;
}

- (NSString *)reuseIdentifier
{
	return @"MyCellIdentifier";
}

- (NSDictionary *)attributesForCell:(UITableViewCell *)cell withObject:(id)object
{
	if (self.dataSource) {
		return [self.dataSource attributesForCell:cell withObject:object];
	}
	
	// Empty dict
	return [NSDictionary dictionary];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	// Use your object
	//	id object = [self objectForIndexPath:indexPath];
	
}


#pragma mark -
#pragma mark  Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
	if (self.dataSource) {
		return [self.dataSource numberOfSectionsInTableView:tableView];
	}
	
	if (self.fetchedResultsController) {
		return [[self.fetchedResultsController sections] count];
	}
	
	// Check if content first elemetn return array or not
	// If yes, tableview has more than one section
	if (self.content && self.content.count > 0
		&& [[self.content objectAtIndex:0]respondsToSelector:@selector(objectAtIndex:)]) {
		return self.content.count;
	}
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	if (self.dataSource) {
		return [self.dataSource tableView:tableView numberOfRowsInSection:section];
	}
	
	if (self.fetchedResultsController) {
		id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
		return [sectionInfo numberOfObjects];
	}
	
	// Check if content first elemetn return array or not
	// If yes, tableview has more than one section
	if (self.content && self.content.count > section
		&& [[self.content objectAtIndex:section]respondsToSelector:@selector(objectAtIndex:)]) {
		return [[self.content objectAtIndex:section]count];
	}
	return self.content.count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.dataSource) {
		return [self.dataSource tableView:tableView cellForRowAtIndexPath:indexPath];
	}
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.reuseIdentifier];
    if (cell == nil) {
        cell = [[[self.cellClass alloc] initWithStyle:self.cellStyle reuseIdentifier:self.reuseIdentifier] autorelease];
    }
	
	id object = [self objectForIndexPath:indexPath];
    
	// Configure the cell.
	NSDictionary *cellAttributes = [self attributesForCell:cell withObject:object];
	
	for (NSString *keypath in cellAttributes) {
		[cell setValue:[cellAttributes valueForKey:keypath] forKeyPath:keypath];
	}
	
    return cell;
}

- (id)objectForIndexPath:(NSIndexPath *)indexPath
{
	if (self.dataSource) {
		return [self.dataSource objectForIndexPath:indexPath];
	}
	
	if (self.fetchedResultsController) {
		return [self.fetchedResultsController objectAtIndexPath:indexPath];
	}
	
	// Hack to see if array has got multiple sections or not
	NSArray *firstLevel = nil;
	if (self.content && self.content.count > indexPath.section
		&& [[self.content objectAtIndex:indexPath.section]respondsToSelector:@selector(objectAtIndex:)] 
		&& self.content.count>indexPath.section) {
		firstLevel = [self.content objectAtIndex:indexPath.section];
	} else {
		firstLevel = self.content;
	}
	// if nothing return nil
	return (self.content.count>indexPath.row)?[self.content objectAtIndex:indexPath.row]:nil; 
}

#pragma mark -
#pragma mark Fetch Results Controlelr

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (self.dataSource.fetchedResultsController) {
		return self.dataSource.fetchedResultsController;
	}
	
//	if (fetchedResultsController != nil) {
//        return fetchedResultsController;
//    }
//    
//    /*
//	 Set up the fetched results controller.
//	 */
//	// Create the fetch request for the entity.
//	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//	// Edit the entity name as appropriate.
//	NSEntityDescription *entity = [NSEntityDescription entityForName:@"GPProduct" inManagedObjectContext:self.managedObjectContext];
//	[fetchRequest setEntity:entity];
//	
//	// Edit the sort key as appropriate.
//	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"Event" ascending:YES];
//	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
//	
//	[fetchRequest setSortDescriptors:sortDescriptors];
//	
//	// Edit the section name key path and cache name if appropriate.
//    // nil for section name key path means "no sections".
//	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
//    aFetchedResultsController.delegate = self;
//	self.fetchedResultsController = aFetchedResultsController;
//	
//	[aFetchedResultsController release];
//	[fetchRequest release];
//	[sortDescriptor release];
//	[sortDescriptors release];
//	
//	return fetchedResultsController;
	return nil;
}

#pragma mark -
#pragma mark Show Error

- (void)showUserErrorWithTitle:(NSString *)title message:(NSString *)message
{
	// Inform the user regarding problem
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title 
													message:message
												   delegate:nil cancelButtonTitle:nil 
										  otherButtonTitles:@"OK", nil];
	alert.delegate = self;
	[alert show];	
	[alert release];
}

#pragma mark -
#pragma mark Show Loading View

- (void)showLoadingView:(BOOL)show withText:(NSString *)text
{
	// Nothing, up to the subclassing controller to implement this
}

#pragma mark -
#pragma mark Restore Levels

- (void)restoreLevelWithSelectionArray:(NSArray *)selectionArray
{
	// nothing
}

#pragma mark -
#pragma mark Execut Method When Notification Fire

//help executing a method when a notification fire
- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object 
						change:(NSDictionary *)change 
					   context:(void *)context
{
	[self performSelector: (SEL)context withObject: change];
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
	[[NSNotificationCenter defaultCenter]removeObserver:self];
	
	[_object release];
	[_managedObjectContext release];
	[_entityName release];
	[_fetchedResultsController release];
	[_dataSource release];
	[_dumpedFilePath release];
	[_content release];
	
    [super dealloc];
}


@end

