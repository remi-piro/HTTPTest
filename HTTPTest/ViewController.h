//
//  ViewController.h
//  HTTPTest
//
//  Created by lion on 1/24/13.
//  Copyright (c) 2013 lion. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FlipImageBrowser.h"

@interface ViewController : UIViewController

@property(nonatomic, weak) IBOutlet FlipImageBrowser *imageBrowser;

- (IBAction)doOpen:(id)sender;
- (IBAction)doClose:(id)sender;

- (IBAction)doTest1:(id)sender;
- (IBAction)doTest2:(id)sender;

@end
