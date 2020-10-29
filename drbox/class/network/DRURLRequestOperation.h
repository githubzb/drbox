//
//  DRURLRequestOperation.h
//  drbox
//
//  Created by dr.box on 2020/8/21.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRSecPolicy.h"

NS_ASSUME_NONNULL_BEGIN

@interface DRURLRequestOperation : NSOperation <NSURLSessionTaskDelegate, NSURLSessionDataDelegate, NSURLSessionDownloadDelegate>

@property (nonatomic, strong, readonly) NSURLRequest *request;
@property (nonatomic, strong, readonly, nullable) NSURLResponse *response;
@property (nonatomic, strong, readonly, nullable) NSURLSessionTask *task;
@property (nonatomic, strong, readonly, nullable) NSURLSessionTaskMetrics *metrics API_AVAILABLE(ios(10.0));
@property (nonatomic, weak, nullable) id<DRSecPolicy> securityPolicy;

- (nullable instancetype)initWithRequest:(NSURLRequest *)request
                               inSession:(NSURLSession *)session NS_DESIGNATED_INITIALIZER;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

@end

NS_ASSUME_NONNULL_END
