//
//  DRURLSessionManager.m
//  drbox
//
//  Created by dr.box on 2020/8/21.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DRURLSession.h"
#import "DRSecurityPolicy.h"
#import "DRURLRequestOperation.h"

@interface DRURLSession ()<NSURLSessionDelegate,
NSURLSessionTaskDelegate,
NSURLSessionDataDelegate,
NSURLSessionDownloadDelegate>

@property (readwrite, nonatomic, strong) NSURLSessionConfiguration *sessionConfiguration;
@property (readwrite, nonatomic, strong) NSURLSession *session;
/// 请求任务队列
@property (nonatomic, strong) NSOperationQueue *requestQueue;
/// 用于存储进行中的任务
@property (nonatomic, strong) NSMutableDictionary<NSURL *, DRURLRequestOperation *> *requestOperations;

#pragma mark - NSURLSessionDelegate block
@property (nonatomic, copy) DRURLSessionDidBecomeInvalidBlock sessionDidBecomeInvalidBlock;
@property (nonatomic, copy) DRURLSessionDidReceiveAuthenticationChallengeBlock sessionDidReceiveAuthenticationChallengeBlock;
@property (nonatomic, copy) DRURLSessionDidFinishEventsForBackgroundURLSessionBlock sessionDidFinishEventsForBackgroundURLSessionBlock;
#pragma mark - NSURLSessionTaskDelegate block
@property (nonatomic, copy) DRTaskWillBeginDelayedRequestBlock taskWillBeginDelayedRequestBlock API_AVAILABLE(ios(11.0));
@property (nonatomic, copy) DRTaskIsWaitingForConnectivityBlock taskIsWaitingForConnectivityBlock;
@property (nonatomic, copy) DRTaskWillPerformHTTPRedirectionBlock taskWillPerformHTTPRedirectionBlock;

@end
@implementation DRURLSession

- (void)dealloc{
    [self.session invalidateAndCancel];
    self.session = nil;
    [self.requestQueue cancelAllOperations];
}

- (instancetype)init{
    return [self initWithSessionConfiguration:nil];
}
- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration{
    self = [super init];
    if (self) {
        if (!configuration) {
            configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        }
        self.sessionConfiguration = configuration;
        self.session = [NSURLSession sessionWithConfiguration:configuration
                                                     delegate:self
                                                delegateQueue:nil];
        self.securityPolicy = [DRSecurityPolicy defaultPolicy];
        self.requestQueue = [[NSOperationQueue alloc] init];
        self.requestQueue.maxConcurrentOperationCount = 6;
        self.requestQueue.name = @"com.drbox.network.queue";
        self.requestOperations = [[NSMutableDictionary alloc] initWithCapacity:6];
    }
    return self;
}

- (void)setMaxConcurrentRequestCount:(NSInteger)maxConcurrentRequestCount{
    self.requestQueue.maxConcurrentOperationCount = maxConcurrentRequestCount;
}
- (NSInteger)maxConcurrentRequestCount{
    return self.requestQueue.maxConcurrentOperationCount;
}

- (void)setSessionDidBecomeInvalidBlock:(DRURLSessionDidBecomeInvalidBlock)block{
    self.sessionDidBecomeInvalidBlock = block;
}
- (void)setSessionDidReceiveAuthenticationChallengeBlock:(DRURLSessionDidReceiveAuthenticationChallengeBlock)block{
    self.sessionDidReceiveAuthenticationChallengeBlock = block;
}
- (void)setSessionDidFinishEventsForBackgroundURLSessionBlock:(DRURLSessionDidFinishEventsForBackgroundURLSessionBlock)block{
    self.sessionDidFinishEventsForBackgroundURLSessionBlock = block;
}
- (void)setTaskWillBeginDelayedRequestBlock:(DRTaskWillBeginDelayedRequestBlock)block{
    self.taskWillBeginDelayedRequestBlock = block;
}

- (void)setTaskIsWaitingForConnectivityBlock:(DRTaskIsWaitingForConnectivityBlock)block{
    self.taskIsWaitingForConnectivityBlock = block;
}
- (void)setTaskWillPerformHTTPRedirectionBlock:(DRTaskWillPerformHTTPRedirectionBlock)block{
    self.taskWillPerformHTTPRedirectionBlock = block;
}

#pragma mark - private
- (DRURLRequestOperation *)operationWithTask:(NSURLSessionTask *)task {
    DRURLRequestOperation *returnOperation = nil;
    for (DRURLRequestOperation *operation in self.requestQueue.operations) {
        NSURLSessionTask *operationTask;
        @synchronized (operation) {
            operationTask = operation.task;
        }
        if (operationTask.taskIdentifier == task.taskIdentifier) {
            returnOperation = operation;
            break;
        }
    }
    return returnOperation;
}

#pragma mark - NSCopying
- (id)copyWithZone:(NSZone *)zone{
    return [[self.class allocWithZone:zone] initWithSessionConfiguration:self.sessionConfiguration];
}

#pragma mark - NSSecureCoding
+ (BOOL)supportsSecureCoding{
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)coder{
    NSURLSessionConfiguration *configuration = [coder decodeObjectOfClass:[NSURLSessionConfiguration class]
                                                                   forKey:@"sessionConfiguration"];
    return [self initWithSessionConfiguration:configuration];
}

- (void)encodeWithCoder:(NSCoder *)coder{
    [coder encodeObject:self.sessionConfiguration forKey:@"sessionConfiguration"];
}

#pragma mark - NSURLSessionDelegate
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(nullable NSError *)error{
    if (self.sessionDidBecomeInvalidBlock) {
        self.sessionDidBecomeInvalidBlock(session, error);
    }
}
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler{
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    __block NSURLCredential *credential = nil;

    if (self.sessionDidReceiveAuthenticationChallengeBlock) {
        disposition = self.sessionDidReceiveAuthenticationChallengeBlock(session, challenge, &credential);
    } else {
        if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
            if ([self.securityPolicy evaluateServerTrust:challenge.protectionSpace.serverTrust
                                               forDomain:challenge.protectionSpace.host]) {
                credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
                if (credential) {
                    disposition = NSURLSessionAuthChallengeUseCredential;
                } else {
                    disposition = NSURLSessionAuthChallengePerformDefaultHandling;
                }
            } else {
                disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
            }
        } else {
            disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        }
    }

    completionHandler(disposition, credential);
}
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session API_AVAILABLE(ios(7.0)){
    if (self.sessionDidFinishEventsForBackgroundURLSessionBlock) {
        self.sessionDidFinishEventsForBackgroundURLSessionBlock(session);
    }
}

#pragma mark - NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
                        willBeginDelayedRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLSessionDelayedRequestDisposition disposition, NSURLRequest * _Nullable newRequest))completionHandler API_AVAILABLE(ios(11.0)){
    NSURLSessionDelayedRequestDisposition disposition = NSURLSessionDelayedRequestCancel;
    __block NSURLRequest *newRequest = nil;
    if (self.taskWillBeginDelayedRequestBlock) {
        disposition = self.taskWillBeginDelayedRequestBlock(session, task, request, &newRequest);
    }
    completionHandler(disposition, newRequest);
}
- (void)URLSession:(NSURLSession *)session taskIsWaitingForConnectivity:(NSURLSessionTask *)task API_AVAILABLE(ios(11.0)){
    if (self.taskIsWaitingForConnectivityBlock) {
        self.taskIsWaitingForConnectivityBlock(session, task);
    }
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
                     willPerformHTTPRedirection:(NSHTTPURLResponse *)response
                                     newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler{
    NSURLRequest *redirectRequest = request;

    if (self.taskWillPerformHTTPRedirectionBlock) {
        redirectRequest = self.taskWillPerformHTTPRedirectionBlock(session, task, response, request);
    }
    completionHandler(redirectRequest);
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
                            didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler{
    
    DRURLRequestOperation *operation = [self operationWithTask:task];
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    __block NSURLCredential *credential = nil;

    if (self.sessionDidReceiveAuthenticationChallengeBlock) {
        disposition = self.sessionDidReceiveAuthenticationChallengeBlock(session, challenge, &credential);
    } else {
        if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
            if ([self.securityPolicy evaluateServerTrust:challenge.protectionSpace.serverTrust
                                               forDomain:challenge.protectionSpace.host]) {
                credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
                if (credential) {
                    disposition = NSURLSessionAuthChallengeUseCredential;
                } else {
                    disposition = NSURLSessionAuthChallengePerformDefaultHandling;
                }
            } else {
                disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
            }
        } else {
            disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        }
    }

    completionHandler(disposition, credential);
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
 needNewBodyStream:(void (^)(NSInputStream * _Nullable bodyStream))completionHandler{
    
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
                                didSendBodyData:(int64_t)bytesSent
                                 totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend{
    
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didFinishCollectingMetrics:(NSURLSessionTaskMetrics *)metrics API_AVAILABLE(ios(10.0)){
    
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error{
    
}

#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
                                 didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler{
    
}
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask{
    
}
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didBecomeStreamTask:(NSURLSessionStreamTask *)streamTask{
    
}
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data{
    
}
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
                                  willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse * _Nullable cachedResponse))completionHandler{
    
}

#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location{
    
}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
                                           didWriteData:(int64_t)bytesWritten
                                      totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    
}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
                                      didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes{
    
}

@end
