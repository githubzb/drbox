//
//  DRURLSessionManager.h
//  drbox
//
//  Created by dr.box on 2020/8/21.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRSecPolicy.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^DRURLSessionDidBecomeInvalidBlock)(NSURLSession *session, NSError *error);
typedef NSURLSessionAuthChallengeDisposition (^DRURLSessionDidReceiveAuthenticationChallengeBlock)(NSURLSession *session,
                                                                                                   NSURLAuthenticationChallenge *challenge,
                                                                                                   NSURLCredential * _Nullable * _Nullable credential);
typedef void (^DRURLSessionDidFinishEventsForBackgroundURLSessionBlock)(NSURLSession *session);
typedef NSURLSessionDelayedRequestDisposition (^DRTaskWillBeginDelayedRequestBlock)(NSURLSession *session,
                                                                                    NSURLSessionTask *task,
                                                                                    NSURLRequest *delayedRequest,
                                                                                    NSURLRequest * _Nullable * _Nullable newRequest) API_AVAILABLE(ios(11.0));
typedef void(^DRTaskIsWaitingForConnectivityBlock)(NSURLSession *session,
                                                   NSURLSessionTask *task);

typedef NSURLRequest * _Nullable (^DRTaskWillPerformHTTPRedirectionBlock)(NSURLSession *session,
                                                                          NSURLSessionTask *task,
                                                                          NSHTTPURLResponse *response,
                                                                          NSURLRequest *newRequest);

typedef void(^DRRequestProgressBlock)(NSProgress *progress);
typedef void(^DRRequestCompletionBlock)(NSURLResponse *response,
                                        id _Nullable responseObject,
                                        NSError * _Nullable error);

@interface DRURLSession: NSObject<NSCopying, NSSecureCoding>

/// SSL验证策略，默认：[DRSecurityPolicy defaultPolicy]
@property (nonatomic, strong) id<DRSecPolicy> securityPolicy;

/// 设置request并发最大个数，默认：6
@property (nonatomic, assign) NSInteger maxConcurrentRequestCount;



- (instancetype)initWithSessionConfiguration:(nullable NSURLSessionConfiguration *)configuration NS_DESIGNATED_INITIALIZER;


- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                               uploadProgress:(nullable DRRequestProgressBlock)uploadProgressBlock
                             downloadProgress:(nullable DRRequestProgressBlock)downloadProgressBlock
                            completionHandler:(nullable DRRequestCompletionBlock)completionHandler;


#pragma mark - NSURLSessionDelegate block
- (void)setSessionDidBecomeInvalidBlock:(DRURLSessionDidBecomeInvalidBlock)block;
- (void)setSessionDidReceiveAuthenticationChallengeBlock:(DRURLSessionDidReceiveAuthenticationChallengeBlock)block;
- (void)setSessionDidFinishEventsForBackgroundURLSessionBlock:(DRURLSessionDidFinishEventsForBackgroundURLSessionBlock)block;

#pragma mark - NSURLSessionTaskDelegate block
- (void)setTaskWillBeginDelayedRequestBlock:(DRTaskWillBeginDelayedRequestBlock)block API_AVAILABLE(ios(11.0));
- (void)setTaskIsWaitingForConnectivityBlock:(DRTaskIsWaitingForConnectivityBlock)block API_AVAILABLE(ios(11.0));
- (void)setTaskWillPerformHTTPRedirectionBlock:(DRTaskWillPerformHTTPRedirectionBlock)block;

@end

NS_ASSUME_NONNULL_END
