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


- (void)loadImageJob
{
    NSLog(@"loading images...");
    
    CvCapture *video = cvCreateFileCapture("/Users/lion/Documents/Simpsons.mp4");
    
    NSLog(@"video is %p", video);
    
    if (video) {
        int nbFrames = (int)cvGetCaptureProperty(video, CV_CAP_PROP_FRAME_COUNT);
        
        NSLog(@"found %d frames", nbFrames);
        
        IplImage *frame = cvQueryFrame(video);
        
        NSLog(@"frame %p", frame);
        
        cvReleaseCapture(&video);
    }
}

- (void)loadImage
{
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadImageJob) object:nil];

    [self.queue addOperation:operation];
}

@end
