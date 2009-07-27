//
//  LoginOperation.h
//  ForgetMeNot
//
//  Created by Anthony Mittaz on 8/08/08.
//  Copyright 2008 Anthont Mittaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>

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
	
	id<DefaultOperationDelegate> _delegate;
}

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

@property (assign) id delegate;

- (id)initWithURL:(NSURL *)anUrl infoDictionary:(NSDictionary *)anInfoDictionary;

- (NSData *)downloadUrl;

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