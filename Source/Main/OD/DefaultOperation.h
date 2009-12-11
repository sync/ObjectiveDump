//
//  LoginOperation.h
//  ForgetMeNot
//
//  Created by Anthony Mittaz on 8/08/08.
//  Copyright 2008 Anthont Mittaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>

// Parsing error
// (aka 403, permission denied, aka 404 file not found, aka Unable to download the page when behind a proxy that redirect content, etc...)
#define EmptyContentParserError @"EMPTY CONTENT" 
// (if the user is still unable to download the requested file after 30 second)
#define TimeoutContentParserError @"TIME OUT"
// Operation is canceled
#define OperationCanceledError @"OPERATION CANCELED"

@protocol DefaultOperationDelegate;

@interface DefaultOperation : NSOperation {
	NSURL *url;
	NSDictionary *infoDictionary;
	
	NSString *user;
	NSString *password;
	
	BOOL peformedSelectorOnce;
	
	NSData *bodyData;
	
	NSString *requestMethod;
	NSString *contentType;
	NSString *accept;
	NSString *acceptEncoding;
	
	NSInteger responseStatusCode;
	
	NSString *_tmpFilePath;
	NSFileHandle *_tmpFileHandle;
	
	NSTimeInterval _timeOutSeconds;
	BOOL _timedOut;
	
	NSInteger _offset;
	
	BOOL _hadFoundAtLeastOneItem;
	BOOL _gzipped;
	
	id<DefaultOperationDelegate> _delegate;
	
	id _additionalObject;
}

@property (nonatomic, retain) id additionalObject;

@property (nonatomic) NSTimeInterval timeOutSeconds;

@property (nonatomic, retain) NSString *tmpFilePath;
@property (nonatomic, retain) NSFileHandle *tmpFileHandle;

@property (retain) NSURL *url;
@property (retain) NSDictionary *infoDictionary;
@property BOOL peformedSelectorOnce;
@property (nonatomic, copy) NSString *user;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, retain) NSData *bodyData;
@property (nonatomic, copy) NSString *requestMethod;
@property (nonatomic, copy) NSString *contentType;
@property (nonatomic, copy) NSString *accept;
@property NSInteger responseStatusCode;
@property (nonatomic, copy) NSString *acceptEncoding;
@property (nonatomic) BOOL timedOut;
@property (nonatomic) NSInteger offset;
@property (nonatomic) BOOL hadFoundAtLeastOneItem;
@property (nonatomic) BOOL gzipped;

@property (assign) id delegate;

- (id)initWithURL:(NSURL *)anUrl infoDictionary:(NSDictionary *)anInfoDictionary;

- (NSData *)downloadUrl;
- (void)handleResponse:(NSData *)responseData;

- (NSString *)bundlePathForRessource:(NSString *)aRessource ofType:(NSString *)aType;

- (void)startOperation;
- (void)finishOperationWithObject:(id)object;
- (void)failOperationWithErrorString:(NSString *)errorString;

@end

@protocol DefaultOperationDelegate <NSObject>

@optional

- (void)defaultOperationDidStartLoadingWithInfo:(NSDictionary *)info;
- (void)defaultOperationDidFailWithInfo:(NSDictionary *)info;
- (void)defaultOperationDidFinishLoadingWithInfo:(NSDictionary *)info;


@end