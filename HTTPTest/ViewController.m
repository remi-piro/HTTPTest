//
//  ViewController.m
//  HTTPTest
//
//  Created by lion on 1/24/13.
//  Copyright (c) 2013 lion. All rights reserved.
//

#import "ViewController.h"

#import "ImageService.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    ImageService *service = [[ImageService alloc] init];
    [service loadImage];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
