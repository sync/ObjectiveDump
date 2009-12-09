//
//  BaseGridViewController.h
//  ObjectiveDump
//
//  Created by Anthony Mittaz on 2/12/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "BaseViewController.h"
#import "ODGridView.h"
#import "BaseGridViewDataSource.h"
#import "ODImageDownloader.h"

@protocol BaseGridViewControllerSubclass <NSObject>

@optional

// Non persistent content
@property (nonatomic, readonly) NSMutableArray *content;

// Image loading
- (void)loadImagesForOnscreenRows;

@end


@interface BaseGridViewController : UIViewController <UIAlertViewDelegate, BaseViewControllerSubclass, BaseGridViewControllerSubclass, ODGridViewDataSource, ODGridViewDelegate, UIScrollViewDelegate, ODImageDownloaderDelegate> {
	
	ODGridView *_gridView;
	
	// Non persitent content
	NSMutableArray *_content;
	NSString *_dumpedFilePath;
	
	// Persitent content
	NSString *_entityName;
	
	// Get the context
	NSManagedObjectContext *_managedObjectContext;
	
	BaseGridViewDataSource *_dataSource;
	
	id _object;
	
	BOOL _viewDidLoadCalled;
	
	NSOperationQueue *_imageDownloadQueue;
}

@property (nonatomic, retain) IBOutlet ODGridView *gridView;
@property (nonatomic, copy) NSString *dumpedFilePath;
@property (nonatomic, retain) BaseGridViewDataSource *dataSource;
@property (nonatomic, retain) id object;
@property (nonatomic) BOOL viewDidLoadCalled;
@property (nonatomic, readonly) NSOperationQueue *imageDownloadQueue;

// Loading View
- (void)showLoadingViewForText:(NSString *)loadingText;
- (void)hideLoadingView;

// Error View
- (void)showErrorViewForText:(NSString *)errorText;
- (void)hideErrorView;

// Build Next Url
- (NSURL *)buildNextUrlWithOffset:(NSInteger)offset limit:(NSInteger)limit urlString:(NSString *)urlString;
// Core Data
- (BOOL)saveContextAndHandleErrors;

// Images loading
- (void)startImageDownload:(NSString *)url forIndex:(NSNumber *)index resizeSize:(CGSize)resizeSize;

@end
