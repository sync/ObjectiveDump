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

- (NSArray *)content
{
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
	NSDictionary *cellAttributes = [self attributesForCell:cell withObject:object];
	
	for (NSString *keypath in cellAttributes) {
		[cell setValue:[cellAttributes valueForKey:keypath] forKeyPath:keypath];
	}
	
    return cell;
}

- (NSDictionary *)attributesForCell:(UITableViewCell *)cell withObject:(id)object
{
	// Empty dict
	return [NSDictionary dictionary];
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

#pragma mark Show Loading View

- (void)showLoadingView:(BOOL)show withText:(NSString *)text
{
	// Nothing, up to the subclassing controller to implement this
}


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
	
	[_appDelegate release];
	
    [super dealloc];
}


@end

