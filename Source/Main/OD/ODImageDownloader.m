/*
     File: ODImageDownloader.m 
 Abstract: Helper object for managing the downloading of a particular app's icon.
 As a delegate "NSURLConnectionDelegate" is downloads the app icon in the background if it does not
 yet exist and works in conjunction with the RootViewController to manage which apps need their icon.
 
 A simple BOOL tracks whether or not a download is already in progress to avoid redundant requests.
  
  Version: 1.0 
  
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple 
 Inc. ("Apple") in consideration of your agreement to the following 
 terms, and your use, installation, modification or redistribution of 
 this Apple software constitutes acceptance of these terms.  If you do 
 not agree with these terms, please do not use, install, modify or 
 redistribute this Apple software. 
  
 In consideration of your agreement to abide by the following terms, and 
 subject to these terms, Apple grants you a personal, non-exclusive 
 license, under Apple's copyrights in this original Apple software (the 
 "Apple Software"), to use, reproduce, modify and redistribute the Apple 
 Software, with or without modifications, in source and/or binary forms; 
 provided that if you redistribute the Apple Software in its entirety and 
 without modifications, you must retain this notice and the following 
 text and disclaimers in all such redistributions of the Apple Software. 
 Neither the name, trademarks, service marks or logos of Apple Inc. may 
 be used to endorse or promote products derived from the Apple Software 
 without specific prior written permission from Apple.  Except as 
 expressly stated in this notice, no other rights or licenses, express or 
 implied, are granted by Apple herein, including but not limited to any 
 patent rights that may be infringed by your derivative works or by other 
 works in which the Apple Software may be incorporated. 
  
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE 
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION 
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS 
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND 
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 
  
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL 
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, 
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED 
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), 
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE 
 POSSIBILITY OF SUCH DAMAGE. 
  
 Copyright (C) 2009 Apple Inc. All Rights Reserved. 
  
 */

#import "ODImageDownloader.h"

@implementation ODImageDownloader

@synthesize resizeSize=_resizeSize;
@synthesize index=_index;
@synthesize imageDelegate=_imageDelegate;

- (void)main
{
	
	if ([self isCancelled])
	{
		return;  // user cancelled this operation
	}
	
	NSData *responseData = [self downloadUrl];
	
	if ([responseData length] != 0)  {
        
		if (![self isCancelled])
		{
			// Set appIcon and clear temporary data/image
			UIImage *image = [UIImage imageWithData:responseData];
			
			if (image.size.width != self.resizeSize.width && image.size.height != self.resizeSize.height)
			{
				image = [self createImage:image.CGImage width:self.resizeSize.width height:self.resizeSize.height];
			}
			
			// call our delegate and tell it that our image is ready for display
			if (self.imageDelegate && [self.imageDelegate respondsToSelector:@selector(imageDownloaderDidLoadImage:forIndex:)]) {
				//[self.delegate performSelectorOnMainThread:@selector(defaultOperationDidFailWithInfo:) withObject:dict waitUntilDone:TRUE];
				[self.imageDelegate imageDownloaderDidLoadImage:image forIndex:self.index];
			}
		}
	}
}

// Coming from http://stackoverflow.mobi/question1043937_Multiple-Image-Operations-Crash-iPhone-App.aspx
// Draw the image into a pixelsWide x pixelsHigh bitmap and use that bitmap to 
// create a new UIImage 
- (UIImage *)createImage:(CGImageRef)image width:(CGFloat)pixelWidth height:(CGFloat)pixelHeight
{ 
    // Set the size of the output image 
    CGRect aRect = CGRectMake(0.0f, 0.0f, pixelWidth, pixelHeight); 
    // Create a bitmap context to store the new thumbnail 
    CGContextRef context = MyCreateBitmapContext(pixelWidth, pixelHeight); 
    // Clear the context and draw the image into the rectangle 
    CGContextClearRect(context, aRect); 
    CGContextDrawImage(context, aRect, image); 
    // Return a UIImage populated with the new resized image 
    CGImageRef myRef = CGBitmapContextCreateImage (context); 
	
    UIImage *img = [UIImage imageWithCGImage:myRef];
	
    free(CGBitmapContextGetData(context)); 
    CGContextRelease(context);
    CGImageRelease(myRef);
	
    return img; 
} 


// MyCreateBitmapContext: Source based on Apple Sample Code
CGContextRef MyCreateBitmapContext (CGFloat pixelsWide,
									CGFloat pixelsHigh)
{
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
	
    bitmapBytesPerRow   = (pixelsWide * 4);
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
	
    colorSpace = CGColorSpaceCreateDeviceRGB();
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL)
    {
        fprintf (stderr, "Memory not allocated!");
		CGColorSpaceRelease( colorSpace );
        return NULL;
    }
    context = CGBitmapContextCreate (bitmapData,
									 pixelsWide,
									 pixelsHigh,
									 8,
									 bitmapBytesPerRow,
									 colorSpace,
									 kCGImageAlphaPremultipliedLast);
    if (context== NULL)
    {
        free (bitmapData);
		CGColorSpaceRelease( colorSpace );
        fprintf (stderr, "Context not created!");
        return NULL;
    }
    CGColorSpaceRelease( colorSpace );
	
    return context;
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	
	[_index release];
	
	[super dealloc];
}


@end

