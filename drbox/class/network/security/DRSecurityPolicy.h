//
//  DRSecurityPolicy.h
//  drbox
//
//  Created by dr.box on 2020/8/23.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRSecPolicy.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, DRSSLPinningMode) {
    /// 只对证书中的域名做验证
    DRSSLPinningModeNone,
    /// 只对证书中的公钥做验证
    DRSSLPinningModePublicKey,
    /// 对证书全部内容做验证
    DRSSLPinningModeCertificate,
};

@interface DRSecurityPolicy : NSObject <DRSecPolicy, NSSecureCoding, NSCopying>

/// 证书验证模式
@property (readonly, nonatomic, assign) DRSSLPinningMode SSLPinningMode;
/// SSL证书二进制数据集合
@property (nonatomic, strong, nullable) NSSet <NSData *> *pinnedCertificates;
/// 是否允许无效或过期的SSL证书信任服务器，默认：NO
@property (nonatomic, assign) BOOL allowInvalidCertificates;
/// 是否验证证书的CN字段中的域名。默认：YES
@property (nonatomic, assign) BOOL validatesDomainName;

/// 获取在bundle下的“.cer”目录下扩展名为cer的所有证书文件
+ (NSSet <NSData *> *)certificatesInBundle:(NSBundle *)bundle;

/// 初始化默认policy，self.SSLPinningMode == DRSSLPinningModeNone
+ (instancetype)defaultPolicy;

/// 初始化policy，证书默认从mainbundle下.cer目录中加载
+ (instancetype)policyWithPinningMode:(DRSSLPinningMode)pinningMode;

/// 初始化policy
+ (instancetype)policyWithPinningMode:(DRSSLPinningMode)pinningMode
               withPinnedCertificates:(NSSet <NSData *> *)pinnedCertificates;

/**
 SSL校验
 
 @param serverTrust X.509证书信任评估
 @param domain serverTrust里的域名，用于校验证书CN字段中的域名，如果为nil，则不去校验
 */
- (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust
                  forDomain:(nullable NSString *)domain;

@end

NS_ASSUME_NONNULL_END
