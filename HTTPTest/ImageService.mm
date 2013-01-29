//
//  ImageService.m
//  HTTPTest
//
//  Created by lion on 1/24/13.
//  Copyright (c) 2013 lion. All rights reserved.
//

#import "ImageService.h"

#import "opencv2/highgui/highgui_c.h"

@interface ImageService ()

@property(nonatomic, strong) NSOperationQueue *queue;

@end

@implementation ImageService

- (id)init
{
    self = [super init];
    
    if (self) {
        self.queue = [[NSOperationQueue alloc] init];
    }
    
    return self;
}

// http://aptogo.co.uk/2011/09/opencv-framework-for-ios/
// http://web.michaelchughes.com/how-to/watch-video-in-python-with-opencv
// http://snipplr.com/view/37888/uiimage-from-iplimage/
// http://stackoverflow.com/questions/4263365/iphone-converting-iplimage-to-uiimage-and-back-causes-rotation

- (UIImage *)UIImageFromIplImage:(IplImage *)image
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // Allocating the buffer for CGImage
    NSData *data = [NSData dataWithBytes:image->imageData length:image->imageSize];
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef) data);
    // Creating CGImage from chunk of IplImage
    CGImageRef imageRef = CGImageCreate(
                                        image->width, image->height,
                                        image->depth, image->depth * image->nChannels, image->widthStep,
                                        colorSpace, kCGImageAlphaNone|kCGBitmapByteOrderDefault,
                                        provider, NULL, false, kCGRenderingIntentDefault
                                        );
    // Getting UIImage from CGImage
    UIImage *ret = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    return ret;
}

- (UIImage *)loadImageJob
{
    NSLog(@"loading image...");
    
    UIImage *image = nil;
    
    CvCapture *video = cvCreateFileCapture("/Users/lion/Documents/Simpsons.mp4");
    
    NSLog(@"video is %p", video);
    
    if (video) {
        int nbFrames = (int)cvGetCaptureProperty(video, CV_CAP_PROP_FRAME_COUNT);
        
        NSLog(@"found %d frames", nbFrames);
        
        IplImage *frame = nil;
        
        int count = 0;

        do {
            frame = cvQueryFrame(video);
            count++;
        } while (frame != nil && count != (24 * 20));
        
        NSLog(@"frame %p", frame);
        
        image = [self UIImageFromIplImage:frame];
        
        cvReleaseCapture(&video);
    }
    
    return image;
}

- (UIImage *)loadImage
{
    /*
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadImageJob) object:nil];

    [self.queue addOperation:operation];
     */
    
    return [self loadImageJob];
}

@end
