//
//  HTTPMediaDownloader.h
//  HTTPTest
//
//  Created by Remi on 11/02/13.
//  Copyright (c) 2013 lion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTTPMediaDownloader : NSObject

+ (HTTPMediaDownloader *)mediaDownloaderWithHost:(NSString *)host;

- (BOOL)open;
- (void)close;
- (void)downloadResource:(NSString *)resource;

@end
