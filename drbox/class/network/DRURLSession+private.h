//
//  DRURLSession+private.h
//  drbox
//
//  Created by dr.box on 2020/8/24.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DRURLSession.h"

NS_ASSUME_NONNULL_BEGIN

@interface DRURLSession (private)

@property (nonatomic, readonly) NSURLSessionConfiguration *sessionConfiguration;
@property (nonatomic, readonly) NSURLSession *session;

@end

NS_ASSUME_NONNULL_END
