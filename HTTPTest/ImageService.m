//
//  ImageService.m
//  HTTPTest
//
//  Created by lion on 1/24/13.
//  Copyright (c) 2013 lion. All rights reserved.
//

#import "ImageService.h"

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

- (void)loadImageJob
{
    NSLog(@"image loaded");
}

- (void)loadImage
{
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadImageJob) object:nil];

    [self.queue addOperation:operation];
}

@end
