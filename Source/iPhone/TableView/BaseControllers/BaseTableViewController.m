//
//  BaseTableViewController.m
//  
//
//  Created by Anthony Mittaz on 5/02/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import "BaseTableViewController.h"
#import "GloballyUniquePathStringAdditions.h"

@implementation BaseTableViewController

@synthesize dumpedFilePath=_dumpedFilePath;

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
}

- (void)viewDidUnload 
{	
	// Empty cell attributes array
	[_cellAttributes release];
	_cellAttributes = nil;
	
	// Empty cell key for attributes
	[_cellKeysForAttributes release];
	_cellKeysForAttributes = nil;
	
	// Dump array content to temporary file
	// Only if non nil and non empty
	if (self.content && [self.content count]>0) {
		self.dumpedFilePath = [NSString globallyUniquePath];
		[self.content writeToFile:self.dumpedFilePath atomically:FALSE];
	}
}

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

- (NSArray *)content
{
	if (!_content) {
		if ([[NSFileManager defaultManager]fileExistsAtPath:self.dumpedFilePath]) {
			_content = [NSArray arrayWithContentsOfFile:self.dumpedFilePath];
			[[NSFileManager defaultManager]removeItemAtPath:self.dumpedFilePath error:nil];
			self.dumpedFilePath = nil;
		} else {
			_content = [[NSArray alloc]init];
		}
	}
	return _content;
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
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 0;
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
	// Hack to see if array has got multiple sections or not
	NSArray *firstLevel = nil;
	if ([[self.content objectAtIndex:indexPath.section]respondsToSelector:@selector(array)] 
		&& self.content.count>indexPath.section) {
		firstLevel = [self.content objectAtIndex:indexPath.section];
	} else {
		firstLevel = self.content;
	}
	// if nothing return nil
	return (self.content.count>indexPath.row)?[self.content objectAtIndex:indexPath.row]:nil; 
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


- (ObjectiveDumpAppDelegate *)appDelegate
{
	if (!_appDelegate) {
		_appDelegate = (ObjectiveDumpAppDelegate *)[[UIApplication sharedApplication]delegate];
	}
	return _appDelegate;
}

- (void)restoreLevelWithSelectionArray:(NSArray *)selectionArray
{
	// nothing
}

//help executing a method when a notification fire
- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object 
						change:(NSDictionary *)change 
					   context:(void *)context
{
	[self performSelector: (SEL)context withObject: change];
}


- (void)dealloc {
	[_dumpedFilePath release];
	[_content release];
	[_cellKeysForAttributes release];
	[_cellAttributes release];
	
	[_appDelegate release];
	
    [super dealloc];
}


@end

