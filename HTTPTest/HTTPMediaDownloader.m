//
//  HTTPMediaDownloader.m
//  HTTPTest
//
//  Created by Remi on 11/02/13.
//  Copyright (c) 2013 lion. All rights reserved.
//

#import "HTTPMediaDownloader.h"

#import <SystemConfiguration/SystemConfiguration.h>

#import "HTTPNetwork.h"

@interface HTTPMediaDownloader () {
    int socketFd;
}

@property(nonatomic, strong) NSString *host;
@property(nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation HTTPMediaDownloader

+ (HTTPMediaDownloader *)mediaDownloaderWithHost:(NSString *)host
{
    HTTPMediaDownloader *md = [[HTTPMediaDownloader alloc] init];
    
    md.host = host;
    md.operationQueue = [[NSOperationQueue alloc] init];
    
    return md;
}

- (void)checkNeedConnectionOpen
{
	// Attempt to ping the host
    const char *host = [self.host UTF8String];
	SCNetworkReachabilityRef reach = SCNetworkReachabilityCreateWithName(kCFAllocatorSystemDefault, host);
	SCNetworkConnectionFlags flags;
	
	// Store reachability flags in the variable, flags.
	SCNetworkReachabilityGetFlags(reach, &flags);
    	
	if(kSCNetworkReachabilityFlagsConnectionRequired & flags) {
        NSLog(@"Establishing connection");
        
		// Can be reached using current connection, but a connection must be established. (Any traffic to the specific node will initiate the connection)
        NSString *urlStr = [NSString stringWithFormat:@"http://%@/", self.host];
		NSURL *url = [NSURL URLWithString:urlStr];
		NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
		NSURLResponse *response = nil;
		
		[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    }
}

- (BOOL)open
{
    [self checkNeedConnectionOpen];
    
    socketFd = HTTPNetworkConnectToHost([self.host UTF8String]);
    
    return (socketFd > 0);
}

- (void)close
{
    HTTPNetworkDisconnectFromHost(socketFd);
}

- (void)downloadResource:(NSString *)resource
{
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        
        NSString *request = [NSString stringWithFormat:@"GET %@ HTTP/1.1\nHost: %@\nAccept-Encoding: identity\nAccept: */*\nConnection: keep-alive\nUser-Agent: AppleCoreMedia/1.0.0.10A403 (iPhone; U; CPU OS 6_0 like Mac OS X; fr_fr)\n\n", resource, self.host];
        
        int ret = HTTPNetworkSend(socketFd, [request UTF8String]);
        
        if (ret == 0) {
            char *responseBody;
            int responseLength;
            
            ret = HTTPNetworkReceive(socketFd, &responseBody, &responseLength);
            
            if (ret == 0) {
                NSLog(@"got %d bytes", responseLength);
                
                HTTPNetworkFreeResponseBody(responseBody);
            }
            else {
                // error
            }
        }
        else {
            // error
        }
    }];
    
    [self.operationQueue addOperation:operation];
}

@end
