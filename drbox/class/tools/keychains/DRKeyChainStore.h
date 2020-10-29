//
//  DRKeychainStore.h
//  drbox
//
//  Created by dr.box on 2020/9/8.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <Foundation/Foundation.h>

/// item的类型
typedef NS_ENUM(NSInteger, DRKeyChainStoreItemClass) {
    DRKeyChainStoreItemClassGenericPassword = 1,
    DRKeyChainStoreItemClassInternetPassword,
};

/// 服务的协议类型
typedef NS_ENUM(NSInteger, DRKeyChainStoreProtocolType) {
    DRKeyChainStoreProtocolTypeFTP = 1,
    DRKeyChainStoreProtocolTypeFTPAccount,
    DRKeyChainStoreProtocolTypeHTTP,
    DRKeyChainStoreProtocolTypeIRC,
    DRKeyChainStoreProtocolTypeNNTP,
    DRKeyChainStoreProtocolTypePOP3,
    DRKeyChainStoreProtocolTypeSMTP,
    DRKeyChainStoreProtocolTypeSOCKS,
    DRKeyChainStoreProtocolTypeIMAP,
    DRKeyChainStoreProtocolTypeLDAP,
    DRKeyChainStoreProtocolTypeAppleTalk,
    DRKeyChainStoreProtocolTypeAFP,
    DRKeyChainStoreProtocolTypeTelnet,
    DRKeyChainStoreProtocolTypeSSH,
    DRKeyChainStoreProtocolTypeFTPS,
    DRKeyChainStoreProtocolTypeHTTPS,
    DRKeyChainStoreProtocolTypeHTTPProxy,
    DRKeyChainStoreProtocolTypeHTTPSProxy,
    DRKeyChainStoreProtocolTypeFTPProxy,
    DRKeyChainStoreProtocolTypeSMB,
    DRKeyChainStoreProtocolTypeRTSP,
    DRKeyChainStoreProtocolTypeRTSPProxy,
    DRKeyChainStoreProtocolTypeDAAP,
    DRKeyChainStoreProtocolTypeEPPC,
    DRKeyChainStoreProtocolTypeNNTPS,
    DRKeyChainStoreProtocolTypeLDAPS,
    DRKeyChainStoreProtocolTypeTelnetS,
    DRKeyChainStoreProtocolTypeIRCS,
    DRKeyChainStoreProtocolTypePOP3S,
};

/// kSecAttrAuthenticationType
typedef NS_ENUM(NSInteger, DRKeyChainStoreAuthType) {
    DRKeyChainStoreAuthTypeNTLM = 1,
    DRKeyChainStoreAuthTypeMSN,
    DRKeyChainStoreAuthTypeDPA,
    DRKeyChainStoreAuthTypeRPA,
    DRKeyChainStoreAuthTypeHTTPBasic,
    DRKeyChainStoreAuthTypeHTTPDigest,
    DRKeyChainStoreAuthTypeHTMLForm,
    DRKeyChainStoreAuthTypeDefault
};

/// kSecAttrAccessible
typedef NS_ENUM(NSInteger, DRKeyChainStoreAccessibility) {
    DRKeyChainStoreAccessibilityWhenUnlocked = 1,
    DRKeyChainStoreAccessibilityAfterFirstUnlock,
    DRKeyChainStoreAccessibilityAlways,
    DRKeyChainStoreAccessibilityWhenPasscodeSetThisDeviceOnly,
    DRKeyChainStoreAccessibilityWhenUnlockedThisDeviceOnly,
    DRKeyChainStoreAccessibilityAfterFirstUnlockThisDeviceOnly,
    DRKeyChainStoreAccessibilityAlwaysThisDeviceOnly
};

/// SecAccessControlCreateFlags
typedef NS_ENUM(unsigned long, DRKeyChainStoreAuthenticationPolicy) {
    DRKeyChainStoreAuthenticationPolicyUserPresence        = 1 << 0,
    DRKeyChainStoreAuthenticationPolicyTouchIDAny          = 1u << 1,
    DRKeyChainStoreAuthenticationPolicyTouchIDCurrentSet   = 1u << 3,
    DRKeyChainStoreAuthenticationPolicyDevicePasscode      = 1u << 4,
    DRKeyChainStoreAuthenticationPolicyControlOr           = 1u << 14,
    DRKeyChainStoreAuthenticationPolicyControlAnd          = 1u << 15,
    DRKeyChainStoreAuthenticationPolicyPrivateKeyUsage     = 1u << 30,
    DRKeyChainStoreAuthenticationPolicyApplicationPassword = 1u << 31,
};


NS_ASSUME_NONNULL_BEGIN

extern NSString *const kDRKeychainErrorDomain;


@interface DRKeyChainStore : NSObject

@property (nonatomic, assign, readonly) DRKeyChainStoreItemClass itemClass;

- (instancetype)init NS_UNAVAILABLE;
/**
 初始化DRKeyChainStoreItemClassGenericPassword类型的keychain
 
 @param service kSecAttrService
 
 @return if service == nil retrun nil
 */
- (nullable instancetype)initWithService:(NSString *)service NS_DESIGNATED_INITIALIZER;

/**
 初始化DRKeyChainStoreItemClassInternetPassword类型的keychain

 @param server kSecAttrServer
 @param protocolType kSecAttrProtocol
 @param authType kSecAttrAuthenticationType

 @return if server == nil retrun nil
*/
- (nullable instancetype)initWithServer:(NSURL *)server
                           protocolType:(DRKeyChainStoreProtocolType)protocolType
                               authType:(DRKeyChainStoreAuthType)authType NS_DESIGNATED_INITIALIZER;

/**
 初始化DRKeyChainStoreItemClassInternetPassword类型的keychain

 @param server kSecAttrServer
 @param protocolType kSecAttrProtocol

 @return if server == nil retrun nil
*/
- (nullable instancetype)initWithServer:(NSURL *)server
                           protocolType:(DRKeyChainStoreProtocolType)protocolType;


/**
 采用DRKeyChainStoreItemClassGenericPassword类型的keychain存储（data不会同步）
 service为bundleIdentifier
 */
+ (BOOL)setData:(NSData *)data forKey:(NSString *)key withError:(NSError * _Nullable* _Nullable)error;

/**
采用DRKeyChainStoreItemClassInternetPassword类型的keychain存储（data会被同步）
service为bundleIdentifier
*/
+ (BOOL)setSyncData:(NSData *)data
             forKey:(NSString *)key
        accessGroup:(NSString *)accessGroup withError:(NSError * _Nullable* _Nullable)error;

/**
采用DRKeyChainStoreItemClassGenericPassword类型的keychain查询data
service为bundleIdentifier
*/
+ (nullable NSData *)dataForKey:(NSString *)key withError:(NSError * _Nullable* _Nullable)error;

/**
采用DRKeyChainStoreItemClassGenericPassword类型的keychain查询data（data为同步的）
service为bundleIdentifier
*/
+ (nullable NSData *)syncDataForKey:(NSString *)key
                        accessGroup:(NSString *)accessGroup
                          withError:(NSError * _Nullable* _Nullable)error;

/**
采用DRKeyChainStoreItemClassGenericPassword类型的keychain存储（str不会被同步）
service为bundleIdentifier
*/
+ (BOOL)setString:(NSString *)str forKey:(NSString *)key withError:(NSError * _Nullable* _Nullable)error;

/**
采用DRKeyChainStoreItemClassGenericPassword类型的keychain存储（str会被同步）
service为bundleIdentifier
*/
+ (BOOL)setSyncString:(NSString *)str
               forKey:(NSString *)key
         accesssGroup:(NSString *)accessGroup
            withError:(NSError * _Nullable* _Nullable)error;

/**
采用DRKeyChainStoreItemClassGenericPassword类型的keychain查询str（str为不同步的）
service为bundleIdentifier
*/
+ (nullable NSString *)stringForKey:(NSString *)key withError:(NSError * _Nullable* _Nullable)error;

/**
采用DRKeyChainStoreItemClassGenericPassword类型的keychain查询str（str为同步的）
service为bundleIdentifier
*/
+ (nullable NSString *)syncStringForKey:(NSString *)key
                           accesssGroup:(NSString *)accessGroup
                              withError:(NSError * _Nullable* _Nullable)error;

/**
 向keychain中添加或更新data（data不会被同步）
 
 @param data if nil, remove data
 @param key 唯一的key
 @param error error info
 
 @return 成功返回YES
 */
- (BOOL)setData:(NSData * _Nullable)data forKey:(NSString *)key withError:(NSError * _Nullable* _Nullable)error;

/**
 向keychain中添加或更新data（data不会被同步）
 
 @param data if nil, remove data
 @param key 唯一的key
 @param useAuthUI 是否添加授权（只对真机起作用）
 @param prompt 授权提示框中的信息
 @param useDataProtectionKeychain 是否使用数据保护密钥链，iOS13开始有效
 @param accessible 授权访问钥匙链策略
 @param policy 授权访问钥匙链策略，iOS8开始有效
 @param error error info
 
 @return 成功返回YES
 */
- (BOOL)setData:(NSData * _Nullable)data
         forKey:(NSString *)key
      useAuthUI:(BOOL)useAuthUI
useOperationPrompt:(NSString * _Nullable)prompt
useDataProtectionKeychain:(BOOL)useDataProtectionKeychain
     accessible:(DRKeyChainStoreAccessibility)accessible
authenticationPolicy:(DRKeyChainStoreAuthenticationPolicy)policy
      withError:(NSError * _Nullable* _Nullable)error;

/**
 向keychain中添加或更新data（data会被同步，只有真机上会同步）
 
 @param data if nil, remove data
 @param key 唯一的key
 @param accessGroup 同步用的keychain access group（注意格式：teamID.bundleIdentifier，否则会存储失败）
 @param error error info
 
 @return 成功返回YES
 */
- (BOOL)setSyncData:(NSData * _Nullable)data
             forKey:(NSString *)key
        accessGroup:(NSString *)accessGroup
          withError:(NSError * _Nullable* _Nullable)error;

/**
 查询keychain中key对应的data
 
 @param key 唯一的key
 @param sync 指定data是否是被同步的（NO：只会查询到非同步的data）
 @param accessGroup 同步用的keychain access group（注意格式：teamID.bundleIdentifier，否则会查找不到; sync==YES时，该值不能为空）
 @param prompt 授权提示框中的信息
 @param error error info
 
 @return 查询出错或未找到返回nil
 */
- (nullable NSData *)fetchDataForKey:(NSString *)key
                              isSync:(BOOL)sync
                         accessGroup:(NSString * _Nullable)accessGroup
                  useOperationPrompt:(NSString * _Nullable)prompt
                           withError:(NSError * _Nullable* _Nullable)error;

/**
 查询keychain中所有的data
 
 @param sync 指定data是否是被同步的（NO：只会查询到非同步的data）
 @param accessGroup 同步用的keychain access group（注意格式：teamID.bundleIdentifier，否则会查找失败; sync==YES时，该值不能为空）
 @param prompt 授权提示框中的信息
 @param error error info
 
 @return 查询出错或未找到返回nil
 */
- (nullable NSArray<NSData *> *)fetchAllDataSync:(BOOL)sync
                                     accessGroup:(NSString * _Nullable)accessGroup
                              useOperationPrompt:(NSString * _Nullable)prompt
                                       withError:(NSError * _Nullable* _Nullable)error;

/**
 删除keychain中指定key的data
 
 @param key 唯一的key
 @param sync 指定data是否是被同步的（NO：只会删除非同步的data）
 @param accessGroup 同步用的keychain access group（注意格式：teamID.bundleIdentifier，否则会删除失败; sync==YES时，该值不能为空）
 @param error error info
 
 @return 删除成功返回YES
 */
- (BOOL)removeDataForkey:(NSString *)key
                  isSync:(BOOL)sync
             accessGroup:(NSString * _Nullable)accessGroup withError:(NSError * _Nullable* _Nullable)error;

/**
 判断keychain中是否存才key对应的data
 
 @param key 唯一的key
 @param sync 指定data是否是被同步的（NO：只会查找非同步的data）
 @param accessGroup 同步用的keychain access group（注意格式：teamID.bundleIdentifier，否则会查找失败; sync==YES时，该值不能为空）
 @param prompt 授权提示框中的信息
 @param error error info
 
 @return 查找到key对应的data，返回YES
 */
- (BOOL)containsForKey:(NSString *)key
                isSync:(BOOL)sync
           accessGroup:(NSString * _Nullable)accessGroup
    useOperationPrompt:(NSString * _Nullable)prompt
             withError:(NSError * _Nullable* _Nullable)error;

- (BOOL)setString:(NSString *)str forKey:(NSString *)key withError:(NSError * _Nullable* _Nullable)error;
- (BOOL)setSyncString:(NSString *)str
               forKey:(NSString *)key
          accessGroup:(NSString *)accessGroup
            withError:(NSError * _Nullable* _Nullable)error;
- (nullable NSString *)stringForKey:(NSString *)key
                 useOperationPrompt:(nullable NSString *)prompt
                          withError:(NSError * _Nullable* _Nullable)error;
- (nullable NSString *)syncStringForKey:(NSString *)key
                            accessGroup:(NSString *)accessGroup
                              withError:(NSError * _Nullable* _Nullable)error;


@end

NS_ASSUME_NONNULL_END
