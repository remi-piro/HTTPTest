//
//  ViewController.m
//  HTTPTest
//
//  Created by lion on 1/24/13.
//  Copyright (c) 2013 lion. All rights reserved.
//

#import "ViewController.h"

#import "ImageService.h"

#import "MediaPlayer/MediaPlayer.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)test1:(id)sender
{
    ImageService *service = [[ImageService alloc] init];
    
    self.imageView.image = [service loadImage];
}

- (IBAction)test3:(id)sender
{
    NSURL *videoURL = [NSURL fileURLWithPath:@"/Users/lion/Documents/Simpsons.mp4"];
    
    MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:videoURL];
    
    UIImage *image = [player thumbnailImageAtTime:0 timeOption:MPMovieTimeOptionNearestKeyFrame];
    
    self.imageView.image = image;
}

- (IBAction)test2:(id)sender
{
    NSURL *videoURL = [NSURL fileURLWithPath:@"/Users/lion/Documents/Simpsons.mp4"];
    
    MPMoviePlayerViewController *playerController = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
    
    [self presentMoviePlayerViewControllerAnimated:playerController];
}

@end

