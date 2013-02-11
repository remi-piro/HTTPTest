//
//  ViewController.m
//  HTTPTest
//
//  Created by lion on 1/24/13.
//  Copyright (c) 2013 lion. All rights reserved.
//

#import "ViewController.h"

#import <SystemConfiguration/SystemConfiguration.h>

#import "ImageService.h"

#import "MediaPlayer/MediaPlayer.h"

#import "network.h"

@interface ViewController () {
    int socket_fd;
}

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

- (void)checkNeedConnectionOpen
{
	// Attempt to ping www.apple.com
	SCNetworkReachabilityRef reach = SCNetworkReachabilityCreateWithName(kCFAllocatorSystemDefault, "www.apple.com");
	SCNetworkConnectionFlags flags;
	
	// Store reachability flags in the variable, flags.
	SCNetworkReachabilityGetFlags(reach, &flags);
    
    NSLog(@"Checking connection");
	
	if(kSCNetworkReachabilityFlagsConnectionRequired & flags)
	{
        NSLog(@"Establishing connection");
                
		// Can be reached using current connection, but a connection must be established. (Any traffic to the specific node will initiate the connection)
		NSURL *url = [NSURL URLWithString:@"http://www.apple.com/"];
		NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
		NSURLResponse *response = nil;
		
		[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    }
}

- (IBAction)doOpen:(id)sender
{
    [self checkNeedConnectionOpen];
    
    socket_fd = openSocket();
    
    NSLog(@"socket %d", socket_fd);
    
    if (socket_fd > 0) {
        int ret;
        
//        ret = sendRequest(socket_fd, "GET /raw_media/remi/hello.txt HTTP/1.1\n");
        ret = sendRequest(socket_fd, "GET /raw_media/channel_10.mp4 HTTP/1.1\n");
        NSLog(@"send %d", ret);
        
        ret = sendRequest(socket_fd, "Host: www3.r3gis.fr\n");
        NSLog(@"send %d", ret);

        ret = sendRequest(socket_fd, "Accept-Encoding: identity\n");
        NSLog(@"send %d", ret);

        ret = sendRequest(socket_fd, "Accept: */*\n");
        NSLog(@"send %d", ret);

        ret = sendRequest(socket_fd, "Accept-Language: fr-fr\n");
        NSLog(@"send %d", ret);

        ret = sendRequest(socket_fd, "Connection: keep-alive\n");
        NSLog(@"send %d", ret);

        ret = sendRequest(socket_fd, "User-Agent: AppleCoreMedia/1.0.0.10A403 (iPhone; U; CPU OS 6_0 like Mac OS X; fr_fr)\n");
        NSLog(@"send %d", ret);

        ret = sendRequest(socket_fd, "\n");
        NSLog(@"send %d", ret);

        ret = receiveResponse(socket_fd);
        NSLog(@"receive %d", ret);
    }
}

- (IBAction)doClose:(id)sender
{
    int ret = closeSocket(socket_fd);
    
    NSLog(@"close socket %d", ret);
}

@end

