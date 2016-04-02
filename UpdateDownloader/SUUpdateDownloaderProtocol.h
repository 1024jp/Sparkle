//
//  SUUpdateDownloaderProtocol.h
//  UpdateDownloader
//
//  Created by Mayur Pawashe on 4/1/16.
//  Copyright © 2016 Sparkle Project. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// The protocol that this service will vend as its API. This header file will also need to be visible to the process hosting the service.
@protocol SUUpdateDownloaderProtocol

- (void)startDownloadWithRequest:(NSURLRequest *)request bundleIdentifier:(NSString *)bundleIdentifier desiredFilename:(NSString *)desiredFilename completion:(void (^)(BOOL success, NSError * _Nullable error))completionBlock;
    
@end

NS_ASSUME_NONNULL_END
