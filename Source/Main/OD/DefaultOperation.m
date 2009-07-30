//
//  LoginOperation.m
//  ForgetMeNot
//
//  Created by Anthony Mittaz on 8/08/08.
//  Copyright 2008 Anthont Mittaz. All rights reserved.
//

#import "DefaultOperation.h"
#import "Base64.h"
#import "NSHTTPCookieAdditions.h"
#import <CFNetwork/CFNetwork.h>

@implementation DefaultOperation

@synthesize url;
@synthesize infoDictionary;
@synthesize peformedSelectorOnce;
@synthesize user;
@synthesize password;
@synthesize bodyData;
@synthesize requestMethod;
@synthesize contentType;
@synthesize accept;
@synthesize responseStatusCode;
@synthesize tmpFilePath=_tmpFilePath;
@synthesize tmpFileHandle=_tmpFileHandle;
@synthesize timeOutSeconds=_timeOutSeconds;
@synthesize delegate=_delegate;
@synthesize acceptEncoding;
@synthesize timedOut=_timedOut;
@synthesize offset=_offset;
@synthesize hadFoundAtLeastOneItem=_hadFoundAtLeastOneItem;


#pragma mark -
#pragma mark Initialisation:

- (id)initWithURL:(NSURL *)anUrl infoDictionary:(NSDictionary *)anInfoDictionary;
{
	self = [super init];
	
	self.url = anUrl;
	self.infoDictionary = anInfoDictionary;
	self.peformedSelectorOnce = FALSE;
	self.requestMethod = @"GET";
	self.contentType = @"text/html; charset=utf-8";
	self.timeOutSeconds = 30.0;
	self.responseStatusCode = 0;
	self.timedOut = FALSE;
	self.offset = 0;
	self.hadFoundAtLeastOneItem = FALSE;
	
	// Buffer
	// downloaded data gets offloaded to the filesystem immediately, to get it out of memory
	NSString * path = [NSTemporaryDirectory() stringByAppendingPathComponent: @"DefaultOperation"];
	[[NSFileManager defaultManager] createDirectoryAtPath: path attributes: nil];
	
	char buf[PATH_MAX];
	[path getCString: buf maxLength: PATH_MAX encoding: NSASCIIStringEncoding];
	NSString *uniqueString = [NSString stringWithFormat:@"/tmp.%@", [[NSProcessInfo processInfo]globallyUniqueString]];
	strlcat(buf, [uniqueString UTF8String], PATH_MAX);
	
	int fd = mkstemp(buf);
	NSString *tmpFilePath = [[NSString alloc] initWithCString: buf encoding: NSASCIIStringEncoding];
	self.tmpFilePath = tmpFilePath;
	[tmpFilePath release];
	NSFileHandle *tmpFileHandle = [[NSFileHandle alloc] initWithFileDescriptor: fd closeOnDealloc: YES];
	self.tmpFileHandle = tmpFileHandle;
	[tmpFileHandle release];
	
    return self;
}

#pragma mark -
#pragma mark This Is Where The Download And Processing Append:

- (void)main
{
	if ([self isCancelled])
	{
		return;  // user cancelled this operation
	}
	
	[self startOperation];
	
	NSData *responseData = [self downloadUrl];
	
	if (self.timedOut) {
		[self failOperationWithErrorString:@"TIMEOUT"];
	} else if ([responseData length] != 0)  {
        
		if (![self isCancelled])
		{
			
			[self finishOperationWithObject:responseData];
		}
	}
}

- (NSData *)downloadUrl
{
	// empty file
	[_tmpFileHandle truncateFileAtOffset: 0];
	
	if (!self.url || [[self.url absoluteString] length] == 0) {
		[self failOperationWithErrorString:@"NOURL"];
		return nil;
	}
	
	// new way
	CFURLRef _uploadURL = CFURLCreateWithString(kCFAllocatorDefault, (CFStringRef)[url absoluteString], NULL);
	CFHTTPMessageRef _request = CFHTTPMessageCreateRequest(kCFAllocatorDefault, (CFStringRef)(self.requestMethod), _uploadURL, kCFHTTPVersion1_1);
	CFRelease(_uploadURL);
	_uploadURL = NULL;
	
	
	// authentification
	if (user != nil && password != nil) {
		Boolean result = CFHTTPMessageAddAuthentication(_request,    // Request
														nil,      // AuthenticationFailureResponse
														(CFStringRef)user,
														(CFStringRef)password,
														kCFHTTPAuthenticationSchemeBasic,
														FALSE);      // ForProxy
		if (result) {
			DLog(@"added authentication for url %@", self.url);
		} else {
			DLog(@"failed to add authentication!");
		}
	}
	
	CFHTTPMessageSetHeaderFieldValue(_request, CFSTR("Content-Type"), (CFStringRef)(self.contentType));
	if (self.accept) {
		CFHTTPMessageSetHeaderFieldValue(_request, CFSTR("Accept"), (CFStringRef)(self.accept));
	}
	CFHTTPMessageSetHeaderFieldValue(_request, CFSTR("User-Agent"), CFSTR("Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_5_6; en-us) AppleWebKit/528.10+ (KHTML, like Gecko) Version/4.0 Safari/528.1"));
	
	if (self.acceptEncoding) {
		CFHTTPMessageSetHeaderFieldValue(_request, CFSTR("Accept-Encoding"), (CFStringRef)(self.acceptEncoding));
	}
	
	// autorisation
	if (user != nil && password != nil) {
		NSString *loginString = [NSString stringWithFormat:@"%@:%@", self.user, self.password];
		NSData *loginStringAsData = [loginString dataUsingEncoding:NSUTF8StringEncoding];
		NSString *base64LoginString = [loginStringAsData base64Encoding];
		NSString *autorisationString = [NSString stringWithFormat:@"Basic (%@)", base64LoginString];
		
		CFHTTPMessageSetHeaderFieldValue(_request, CFSTR("Authorization"), (CFStringRef)(autorisationString));
	}
	
	// Add cookies from the persistant (mac os global) store
	NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];

	// Apply request cookies
	if ([cookies count] > 0) {
	NSHTTPCookie *cookie;
	NSString *cookieHeader = nil;
	for (cookie in cookies) {
	  if (!cookieHeader) {
		cookieHeader = [NSString stringWithFormat: @"%@=%@",[cookie name],[cookie encodedValue]];
	  } else {
		cookieHeader = [NSString stringWithFormat: @"%@; %@=%@",cookieHeader,[cookie name],[cookie encodedValue]];
	  }
	}
	if (cookieHeader) {
	  CFHTTPMessageSetHeaderFieldValue(_request, CFSTR("Cookie"), (CFStringRef)(cookieHeader));
	}
	}
	
	if (self.bodyData) {
		CFHTTPMessageSetHeaderFieldValue(_request, CFSTR("Content-Length"), (CFStringRef)[NSString stringWithFormat: @"%d", [self.bodyData length]]);
		CFHTTPMessageSetBody(_request, (CFDataRef)self.bodyData);
	}
	
	
	CFReadStreamRef _readStream = CFReadStreamCreateForHTTPRequest(kCFAllocatorDefault, _request);
	// Follow redirect
	CFReadStreamSetProperty(_readStream, kCFStreamPropertyHTTPShouldAutoredirect, kCFBooleanTrue);
	CFReadStreamOpen(_readStream);
	
	CFIndex numBytesRead;
	long bytesWritten, previousBytesWritten = 0;
	UInt8 buf[1024];
	BOOL doneUploading = NO;
	
	NSDate *downloadStartedAt = [NSDate date];
	while (!doneUploading) {
		NSMutableData *responseData =  [NSMutableData dataWithLength:0];
		NSDate *now = [NSDate date];
		
		// See if we need to timeout
		if (downloadStartedAt && self.timeOutSeconds > 0 && [now timeIntervalSinceDate:downloadStartedAt] > self.timeOutSeconds) {
			DLog(@"timeout at url: %@", self.url); 
			doneUploading = YES;
			self.timedOut = TRUE;
		}
		
		if ([self isCancelled])
		{
			DLog(@"canceled at url: %@", self.url); 
			doneUploading = YES;
		}
		
		CFNumberRef cfSize = CFReadStreamCopyProperty(_readStream, kCFStreamPropertyHTTPRequestBytesWrittenCount);
		CFNumberGetValue(cfSize, kCFNumberLongType, &bytesWritten);
		CFRelease(cfSize);
		cfSize = NULL;
		
		if (bytesWritten > previousBytesWritten) {
			previousBytesWritten = bytesWritten;
		}
		
		if (!CFReadStreamHasBytesAvailable(_readStream)) {
			usleep(3600);
			continue;
		}
		
		numBytesRead = CFReadStreamRead(_readStream, buf, 1024);
		if (numBytesRead < 1024)
			buf[numBytesRead] = 0;      
		[responseData appendBytes:buf length:numBytesRead];
		
		[self.tmpFileHandle writeData:responseData];
		
		if (CFReadStreamGetStatus(_readStream) == kCFStreamStatusAtEnd) doneUploading = YES;
	}
	
	CFHTTPMessageRef headers = (CFHTTPMessageRef)CFReadStreamCopyProperty(_readStream, kCFStreamPropertyHTTPResponseHeader);
	if (headers) {
		if (CFHTTPMessageIsHeaderComplete(headers)) {
			CFDictionaryRef responseHeaders = CFHTTPMessageCopyAllHeaderFields(headers);
			self.responseStatusCode = CFHTTPMessageGetResponseStatusCode(headers);
			
			// Handle cookies
			NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:(NSDictionary *)responseHeaders forURL:url];
			//[self setResponseCookies:cookies];
			
			CFRelease(responseHeaders);
			responseHeaders = NULL;
			DLog(@"response status code: %d for url: %@", responseStatusCode, self.url);
			
			// Store cookies in global persistent store
			[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:cookies forURL:url mainDocumentURL:nil];
		}
		CFRelease(headers);
		headers = NULL;
	}
	
	CFReadStreamClose(_readStream);
	CFRelease(_request);
	_request = NULL;
	CFRelease(_readStream);
	_readStream = NULL;
	// end new way
	
	return [NSData dataWithContentsOfMappedFile:self.tmpFilePath];
}

- (void)startOperation
{
	if ([self.delegate respondsToSelector:@selector(defaultOperationDidStartLoadingWithInfo:)]) {
		NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
		[dict addEntriesFromDictionary:self.infoDictionary];
		[self.delegate performSelectorOnMainThread:@selector(defaultOperationDidStartLoadingWithInfo:) withObject:dict waitUntilDone:FALSE];
	}
}

- (void)finishOperationWithObject:(id)object
{
	if ([self.delegate respondsToSelector:@selector(defaultOperationDidFinishLoadingWithInfo:)]) {
		NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
		[dict addEntriesFromDictionary:self.infoDictionary];
		[dict setObject:[NSNumber numberWithInteger:self.responseStatusCode] forKey:@"responseStatusCode"];
		[dict setObject:[NSNumber numberWithBool:self.hadFoundAtLeastOneItem] forKey:@"hadFoundAtLeastOneItem"];
		if (object) {
			[dict setObject:object forKey:@"object"];
		}
		[self.delegate performSelectorOnMainThread:@selector(defaultOperationDidFinishLoadingWithInfo:) withObject:dict waitUntilDone:FALSE];
	}
}

- (void)failOperationWithErrorString:(NSString *)errorString
{
	if ([self.delegate respondsToSelector:@selector(defaultOperationDidFailWithInfo:)]) {
		NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
		[dict addEntriesFromDictionary:self.infoDictionary];
		if (errorString) {
			[dict setObject:errorString forKey:@"errorString"];
		}
		[dict setObject:[NSNumber numberWithInteger:self.responseStatusCode] forKey:@"responseStatusCode"];
		[dict setObject:[NSNumber numberWithBool:self.hadFoundAtLeastOneItem] forKey:@"hadFoundAtLeastOneItem"];
		[self.delegate performSelectorOnMainThread:@selector(defaultOperationDidFailWithInfo:) withObject:dict waitUntilDone:FALSE];
	}
}

// Permits to retrive the path for the given file on the application ressources dir
- (NSString *)bundlePathForRessource:(NSString *)aRessource ofType:(NSString *)aType
{
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *path = [bundle pathForResource:aRessource ofType:aType];
	return path;
}

#pragma mark -
#pragma mark Dealloc:

- (void)dealloc
{
	[acceptEncoding release];
	[_tmpFileHandle release];
	[_tmpFilePath release];
	[accept release];
	[contentType release];
	[user release];
	[password release];
	[url release];
	[infoDictionary release];
	[bodyData release];
	[requestMethod release];
	
	[super dealloc];
}

@end
