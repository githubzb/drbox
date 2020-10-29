//
//  DRKeychainStore.m
//  drbox
//
//  Created by dr.box on 2020/9/8.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DRKeyChainStore.h"
#import "DrboxMacro.h"
#import "NSBundle+drbox.h"
#import "NSData+drbox.h"

NSString *const kDRKeychainErrorDomain = @"com.drbox.keychain.error";

static inline void DRSetKeyChainError(NSError **error, OSStatus status){
    if (error == NULL) return;
    NSString *message = nil;
    switch (status) {
        case errSecSuccess: return;
        case errSecUnimplemented: {
            message = @"未实现的功能或操作";
            break;
        }
        case errSecParam: {
            message = @"传递给函数的一个或多个参数无效";
            break;
        }
        case errSecAllocate: {
            message = @"分配内存失败";
            break;
        }
        case errSecNotAvailable: {
            message = @"没有钥匙链。您可能需要重新启动设备";
            break;
        }
        case errSecDuplicateItem: {
            message = @"指定的项已经存在于密钥链中";
            break;
        }
        case errSecItemNotFound: {
            message = @"在密钥链中找不到指定的项";
            break;
        }
        case errSecInteractionNotAllowed: {
            message = @"用户不允许的操作";
            break;
        }
        case errSecDecode: {
            message = @"无法解码所提供的数据";
            break;
        }
        case errSecAuthFailed: {
            message = @"您输入的用户名或密码不正确";
            break;
        }
        case errSecUserCanceled:{
            message = @"您已取消该操作";
            break;
        }
        default: {
            message = @"发生意外错误";
        }
    }
    NSError *err = DRCreateError(kDRKeychainErrorDomain, (NSInteger)status, message);
    DRSetError(error, err);
}

static inline id DRAccessibilityValue(DRKeyChainStoreAccessibility accessibility){
    switch (accessibility) {
        case DRKeyChainStoreAccessibilityWhenUnlocked:
            return (__bridge id)kSecAttrAccessibleWhenUnlocked;
        case DRKeyChainStoreAccessibilityAfterFirstUnlock:
            return (__bridge id)kSecAttrAccessibleAfterFirstUnlock;
        case DRKeyChainStoreAccessibilityAlways:{
            if (@available(iOS 12.0, *)) {
                return (__bridge id)kSecAttrAccessibleAfterFirstUnlock;
            }
            return (__bridge id)kSecAttrAccessibleAlways;
        }
        case DRKeyChainStoreAccessibilityWhenPasscodeSetThisDeviceOnly:{
            if (@available(iOS 8.0, *)) {
                return (__bridge id)kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly;
            }
            return nil;
        }
        case DRKeyChainStoreAccessibilityWhenUnlockedThisDeviceOnly:
            return (__bridge id)kSecAttrAccessibleWhenUnlockedThisDeviceOnly;
        case DRKeyChainStoreAccessibilityAfterFirstUnlockThisDeviceOnly:
            return (__bridge id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly;
        case DRKeyChainStoreAccessibilityAlwaysThisDeviceOnly:{
            if (@available(iOS 12.0, *)) {
                return (__bridge id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly;
            }
            return (__bridge id)kSecAttrAccessibleAlwaysThisDeviceOnly;
        }
        default:
            return nil;
    }
}

static inline SecAccessControlCreateFlags DRKeychainAuthPolicyFlags(DRKeyChainStoreAuthenticationPolicy policy){
    switch (policy) {
        case DRKeyChainStoreAuthenticationPolicyUserPresence:
            return kSecAccessControlUserPresence;
        case DRKeyChainStoreAuthenticationPolicyTouchIDAny:{
            if (@available(iOS 11.3, *)) {
                return kSecAccessControlBiometryAny;
            }else if (@available(iOS 9.0, *)){
                return kSecAccessControlTouchIDAny;
            }
            return 0;
        }
        case DRKeyChainStoreAuthenticationPolicyTouchIDCurrentSet:{
            if (@available(iOS 11.3, *)) {
                return kSecAccessControlBiometryCurrentSet;
            }else if (@available(iOS 9.0, *)){
                return kSecAccessControlTouchIDCurrentSet;
            }
            return 0;
        }
        case DRKeyChainStoreAuthenticationPolicyDevicePasscode:{
            if (@available(iOS 9.0, *)) {
                return kSecAccessControlDevicePasscode;
            }
            return 0;
        }
        case DRKeyChainStoreAuthenticationPolicyControlOr:{
            if (@available(iOS 9.0, *)) {
                return kSecAccessControlOr;
            }
            return 0;
        }
        case DRKeyChainStoreAuthenticationPolicyControlAnd:{
            if (@available(iOS 9.0, *)) {
                return kSecAccessControlAnd;
            }
            return 0;
        }
        case DRKeyChainStoreAuthenticationPolicyPrivateKeyUsage:{
            if (@available(iOS 9.0, *)) {
                return kSecAccessControlPrivateKeyUsage;
            }
            return 0;
        }
        case DRKeyChainStoreAuthenticationPolicyApplicationPassword:{
            if (@available(iOS 9.0, *)) {
                return kSecAccessControlApplicationPassword;
            }
            return 0;
        }
        default:
            return 0;
    }
}

@interface DRKeyChainStore (){
    
    NSString *_service;
    
    NSURL *_server;
    DRKeyChainStoreProtocolType _protocolType;
    DRKeyChainStoreAuthType _authType;
}

@end
@implementation DRKeyChainStore

- (instancetype)initWithService:(NSString *)service{
    NSParameterAssert(service);
    if (!service) return nil;
    self = [super init];
    if (self) {
        _itemClass = DRKeyChainStoreItemClassGenericPassword;
        _service = [service copy];
    }
    return self;
}

- (instancetype)initWithServer:(NSURL *)server
                  protocolType:(DRKeyChainStoreProtocolType)protocolType
                      authType:(DRKeyChainStoreAuthType)authType{
    NSParameterAssert(server);
    if (!server) return nil;
    self = [super init];
    if (self) {
        _itemClass = DRKeyChainStoreItemClassInternetPassword;
        _server = [server copy];
        _protocolType = protocolType;
        _authType = authType;
    }
    return self;
}

- (instancetype)initWithServer:(NSURL *)server protocolType:(DRKeyChainStoreProtocolType)protocolType{
    return [self initWithServer:server
                   protocolType:protocolType
                       authType:DRKeyChainStoreAuthTypeDefault];
}

+ (BOOL)setData:(NSData *)data forKey:(NSString *)key withError:(NSError * _Nullable __autoreleasing *)error{
    DRKeyChainStore *store = [[DRKeyChainStore alloc] initWithService:[NSBundle dr_bundleIdentifier]];
    return [store setData:data forKey:key withError:error];
}

+ (BOOL)setSyncData:(NSData *)data
             forKey:(NSString *)key
        accessGroup:(NSString *)accessGroup withError:(NSError * _Nullable __autoreleasing *)error{
    DRKeyChainStore *store = [[DRKeyChainStore alloc] initWithService:[NSBundle dr_bundleIdentifier]];
    return [store setSyncData:data forKey:key accessGroup:accessGroup withError:error];
}

+ (NSData *)dataForKey:(NSString *)key withError:(NSError * _Nullable __autoreleasing *)error{
    DRKeyChainStore *store = [[DRKeyChainStore alloc] initWithService:[NSBundle dr_bundleIdentifier]];
    return [store fetchDataForKey:key
                           isSync:NO
                      accessGroup:nil
               useOperationPrompt:nil
                        withError:error];
}

+ (NSData *)syncDataForKey:(NSString *)key
               accessGroup:(NSString *)accessGroup
                 withError:(NSError * _Nullable __autoreleasing *)error{
    DRKeyChainStore *store = [[DRKeyChainStore alloc] initWithService:[NSBundle dr_bundleIdentifier]];
    return [store fetchDataForKey:key
                           isSync:YES
                      accessGroup:accessGroup
               useOperationPrompt:nil
                        withError:error];
}

+ (BOOL)setString:(NSString *)str
           forKey:(NSString *)key withError:(NSError * _Nullable __autoreleasing *)error{
    DRKeyChainStore *store = [[DRKeyChainStore alloc] initWithService:[NSBundle dr_bundleIdentifier]];
    return [store setString:str forKey:key withError:error];
}

+ (BOOL)setSyncString:(NSString *)str
               forKey:(NSString *)key
         accesssGroup:(NSString *)accessGroup withError:(NSError * _Nullable __autoreleasing *)error{
    DRKeyChainStore *store = [[DRKeyChainStore alloc] initWithService:[NSBundle dr_bundleIdentifier]];
    return [store setSyncString:str forKey:key accessGroup:accessGroup withError:error];
}

+ (NSString *)stringForKey:(NSString *)key withError:(NSError * _Nullable __autoreleasing *)error{
    DRKeyChainStore *store = [[DRKeyChainStore alloc] initWithService:[NSBundle dr_bundleIdentifier]];
    return [store stringForKey:key useOperationPrompt:nil withError:error];
}

+ (NSString *)syncStringForKey:(NSString *)key
                  accesssGroup:(NSString *)accessGroup
                     withError:(NSError * _Nullable __autoreleasing *)error{
    DRKeyChainStore *store = [[DRKeyChainStore alloc] initWithService:[NSBundle dr_bundleIdentifier]];
    return [store syncStringForKey:key accessGroup:accessGroup withError:error];
}

- (BOOL)setData:(NSData *)data
         forKey:(NSString *)key
      useAuthUI:(BOOL)useAuthUI
useOperationPrompt:(NSString *)prompt
useDataProtectionKeychain:(BOOL)useDataProtectionKeychain
     accessible:(DRKeyChainStoreAccessibility)accessible
authenticationPolicy:(DRKeyChainStoreAuthenticationPolicy)policy
      withError:(NSError * _Nullable __autoreleasing *)error{
    if (!key) {
        [self setError:error
                  code:(NSInteger)errSecParam message:@"key can't be nil."];
        return NO;
    }
    NSMutableDictionary *query = [self query];
    query[(__bridge id)kSecAttrAccount] = key;
    if (@available(iOS 8.0, *)) {
        query[(__bridge id)kSecUseOperationPrompt] = prompt;
    }
    // 查询key是否已存在
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, NULL);
    if (status == errSecSuccess || status == errSecInteractionNotAllowed) {
        if (status == errSecInteractionNotAllowed && floor(NSFoundationVersionNumber) <= floor(1140.11)) { // iOS 8.0.x
            if (data) {
                // 先移除在添加
                if ([self removeDataForkey:key isSync:NO accessGroup:nil withError:error]) {
                     return [self setData:data
                                   forKey:key
                                useAuthUI:useAuthUI
                       useOperationPrompt:prompt
                useDataProtectionKeychain:useDataProtectionKeychain
                               accessible:accessible
                     authenticationPolicy:policy
                                withError:error];
                 }
                return NO;
            }else{
                // 移除
                return [self removeDataForkey:key isSync:NO accessGroup:nil withError:error];
            }
        }else{
            // item已存在
            if (!data) {
                // 移除item
                return [self removeDataForkey:key isSync:NO accessGroup:nil withError:error];
            }
            // 更新item
            NSDictionary *attrToUpdate = [NSDictionary dictionaryWithObject:data
                                                                     forKey:(__bridge id)kSecValueData];
            status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)attrToUpdate);
        }
    }else if (status == errSecItemNotFound){
        // key不存在，直接添加
        if (!data) {
            // data为空，不做任何操作
            return YES;
        }
        // 添加item
#if !TARGET_OS_SIMULATOR
        // 模拟器添加以下无效，并且无法添加成功
        if (@available(iOS 9.0, *)) {
            query[(__bridge id)kSecUseAuthenticationUI] = useAuthUI ? (__bridge id)kSecUseAuthenticationUIAllow : (__bridge id)kSecUseAuthenticationUIFail;
        }else if (@available(iOS 8.0, *)){
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
            query[(__bridge id)kSecUseNoAuthenticationUI] = @(!useAuthUI);
#pragma GCC diagnostic pop
        }
        if (useAuthUI) {
            if (@available(iOS 8.0, *)) {
                NSError *securityError = nil;
                query[(__bridge id)kSecAttrAccessControl] = [self accessControlValueWithAccessible:accessible
                                                                              authenticationPolicy:policy
                                                                                         withError:&securityError];
                if (securityError) {
                    DRSetError(error, securityError);
                    return NO;
                }
            }else{
                // kSecAttrAccessible与kSecAttrAccessControl是互斥的，两者只能选一个，否则报错
               query[(__bridge id)kSecAttrAccessible] = DRAccessibilityValue(accessible);
            }
        }
#endif
        if (@available(iOS 13.0, *)) {
            query[(__bridge id)kSecUseDataProtectionKeychain] = @(useDataProtectionKeychain);
        }
#if DEBUG
        query[(__bridge id)kSecReturnAttributes] = @YES;
        query[(__bridge id)kSecValueData] = data;
        CFTypeRef dicRef = NULL;
        status = SecItemAdd((__bridge CFDictionaryRef)query, &dicRef);
        if (status == errSecSuccess) {
            NSDictionary *dic = (__bridge_transfer NSDictionary *)dicRef;
            NSLog(@"KeyChain SecItemAdd success, return attrs: %@", dic);
        }else{
            if (dicRef) {
                CFRelease(dicRef);
            }
        }
#elif
        status = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
#endif
    }
    if (status != errSecSuccess) {
        DRSetKeyChainError(error, status);
    }
    return status == errSecSuccess;
}

- (BOOL)setData:(NSData *)data forKey:(NSString *)key withError:(NSError * _Nullable __autoreleasing *)error{
    return [self setData:data
                  forKey:key
               useAuthUI:NO
      useOperationPrompt:nil
useDataProtectionKeychain:YES
              accessible:0
    authenticationPolicy:0
               withError:error];
}

- (BOOL)setSyncData:(NSData *)data
             forKey:(NSString *)key
        accessGroup:(NSString *)accessGroup withError:(NSError * _Nullable __autoreleasing *)error{
    if (!key) {
        [self setError:error
                  code:(NSInteger)errSecParam message:@"key can't be nil."];
        return NO;
    }
    if (accessGroup.length == 0) {
        [self setError:error
                  code:(NSInteger)errSecParam message:@"accessGroup can't be nil or empty."];
        return NO;
    }
    NSMutableDictionary *query = [self query];
    query[(__bridge id)kSecAttrAccount] = key;
    query[(__bridge id)kSecAttrSynchronizable] = @YES; // 同步data数据
#if !TARGET_OS_SIMULATOR
    //只有真机可以，模拟器会报：errSecMissingEntitlement
    query[(__bridge id)kSecAttrAccessGroup] = accessGroup;
#endif
    //kSecAttrSynchronizable == YES,不能设置kSecAttrAccessControl和kSecAttrAccessible，否则会失败
    
    // 查询key是否已存在
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, NULL);
    if (status == errSecSuccess || status == errSecInteractionNotAllowed) {
        if (status == errSecInteractionNotAllowed && floor(NSFoundationVersionNumber) <= floor(1140.11)) { // iOS 8.0.x
            if (data) {
                // 先移除，再添加
                if ([self removeDataForkey:key isSync:YES accessGroup:accessGroup withError:error]) {
                    return [self setSyncData:data forKey:key accessGroup:accessGroup withError:error];
                }
                return NO;
            }else{
                // 移除
                return [self removeDataForkey:key isSync:YES accessGroup:accessGroup withError:error];
            }
        }else{
            // 已存在
            if (!data) {
                // 删除
                return [self removeDataForkey:key isSync:YES accessGroup:accessGroup withError:error];
            }
            // 更新
            NSDictionary *attrToUpdate = [NSDictionary dictionaryWithObject:data
                                                                     forKey:(__bridge id)kSecValueData];
            status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)attrToUpdate);
        }
    }else if (status == errSecItemNotFound){
        // 不存在item
        if (!data) {
            // data为空，不做任何操作
            return YES;
        }
        // 添加item
        if (@available(iOS 13.0, *)) {
            query[(__bridge id)kSecUseDataProtectionKeychain] = @YES;
        }
        query[(__bridge id)kSecValueData] = data;
#if DEBUG
        query[(__bridge id)kSecReturnAttributes] = @YES;
        CFTypeRef dicRef = NULL;
        status = SecItemAdd((__bridge CFDictionaryRef)query, &dicRef);
        if (status == errSecSuccess) {
            NSDictionary *dic = (__bridge_transfer NSDictionary *)dicRef;
            NSLog(@"KeyChain SecItemAdd success, return attrs: %@", dic);
        }else{
            if (dicRef) {
                CFRelease(dicRef);
            }
        }
#elif
        status = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
#endif
    }
    if (status != errSecSuccess) {
        DRSetKeyChainError(error, status);
    }
    return status == errSecSuccess;
}

- (NSData *)fetchDataForKey:(NSString *)key
                     isSync:(BOOL)sync
                accessGroup:(NSString *)accessGroup
         useOperationPrompt:(NSString * _Nullable)prompt withError:(NSError * _Nullable __autoreleasing *)error{
    if (!key) return nil;
    if (sync && accessGroup.length == 0) {
        [self setError:error
                  code:(NSInteger)errSecParam message:@"accessGroup can't be nil or empty."];
        return nil;
    }
    NSMutableDictionary *query = [self query];
    query[(__bridge id)kSecAttrAccount] = key;
    if (sync) {
        query[(__bridge id)kSecAttrSynchronizable] = @YES;
#if !TARGET_OS_SIMULATOR
        //只有真机可以，模拟器会报：errSecMissingEntitlement
        query[(__bridge id)kSecAttrAccessGroup] = accessGroup;
#endif
    }
    if (@available(iOS 8.0, *)) {
        query[(__bridge id)kSecUseOperationPrompt] = prompt;
    }
    query[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;
    query[(__bridge id)kSecReturnData] = @YES;
    CFTypeRef dataRef;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &dataRef);
    if (status == errSecSuccess) {
        return (__bridge_transfer NSData *)dataRef;
    }
    if (status != errSecSuccess && status != errSecItemNotFound) {
        DRSetKeyChainError(error, status);
    }
    return nil;
}

- (NSArray<NSData *> *)fetchAllDataSync:(BOOL)sync
                            accessGroup:(NSString *)accessGroup
                     useOperationPrompt:(NSString * _Nullable)prompt withError:(NSError * _Nullable __autoreleasing *)error{
    if (sync && accessGroup.length == 0) {
        [self setError:error
                  code:(NSInteger)errSecParam message:@"accessGroup can't be nil or empty."];
        return nil;
    }
    NSMutableDictionary *query = [self query];
    if (sync) {
        query[(__bridge id)kSecAttrSynchronizable] = @YES;
#if !TARGET_OS_SIMULATOR
        //只有真机可以，模拟器会报：errSecMissingEntitlement
        query[(__bridge id)kSecAttrAccessGroup] = accessGroup;
#endif
    }
    if (@available(iOS 8.0, *)) {
        query[(__bridge id)kSecUseOperationPrompt] = prompt;
    }
    query[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitAll;
    query[(__bridge id)kSecReturnData] = @YES;
    CFTypeRef arrRef;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &arrRef);
    if (status == errSecSuccess) {
        return (__bridge_transfer NSArray *)arrRef;
    }
    if (status != errSecSuccess && status != errSecItemNotFound) {
        DRSetKeyChainError(error, status);
    }
    return nil;
}

- (BOOL)removeDataForkey:(NSString *)key
                  isSync:(BOOL)sync
             accessGroup:(NSString *)accessGroup withError:(NSError * _Nullable __autoreleasing *)error{
    if (!key) return NO;
    if (sync && accessGroup.length == 0) {
        [self setError:error
                  code:(NSInteger)errSecParam message:@"sync==YES,accessGroup can't be nil or empty."];
        return NO;
    }
    NSMutableDictionary *query = [self query];
    query[(__bridge id)kSecAttrAccount] = key;
    if (sync) {
        query[(__bridge id)kSecAttrSynchronizable] = @YES;
#if !TARGET_OS_SIMULATOR
        //只有真机可以，模拟器会报：errSecMissingEntitlement
        query[(__bridge id)kSecAttrAccessGroup] = accessGroup;
#endif
    }
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
    return status == errSecSuccess || status == errSecItemNotFound;
}

- (BOOL)containsForKey:(NSString *)key
                isSync:(BOOL)sync
           accessGroup:(NSString *)accessGroup
    useOperationPrompt:(NSString * _Nullable)prompt
             withError:(NSError * _Nullable __autoreleasing *)error{
    if (!key) return NO;
    if (sync && accessGroup.length == 0) {
        [self setError:error
                  code:(NSInteger)errSecParam message:@"sync==YES,accessGroup can't be nil or empty."];
        return NO;
    }
    NSMutableDictionary *query = [self query];
    query[(__bridge id)kSecAttrAccount] = key;
    if (sync) {
        query[(__bridge id)kSecAttrSynchronizable] = @YES;
#if !TARGET_OS_SIMULATOR
        //只有真机可以，模拟器会报：errSecMissingEntitlement
        query[(__bridge id)kSecAttrAccessGroup] = accessGroup;
#endif
    }
    if (@available(iOS 8.0, *)) {
        query[(__bridge id)kSecUseOperationPrompt] = prompt;
    }
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, NULL);
    if (status != errSecSuccess && status != errSecItemNotFound) {
        DRSetKeyChainError(error, status);
    }
    return status == errSecSuccess;
}

- (BOOL)setString:(NSString *)str forKey:(NSString *)key withError:(NSError * _Nullable __autoreleasing *)error{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    return [self setData:data forKey:key withError:error];
}

- (BOOL)setSyncString:(NSString *)str
               forKey:(NSString *)key
          accessGroup:(nonnull NSString *)accessGroup
            withError:(NSError * _Nullable __autoreleasing * _Nullable)error{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    return [self setSyncData:data
                      forKey:key
                 accessGroup:accessGroup
                   withError:error];
}

- (NSString *)stringForKey:(NSString *)key
        useOperationPrompt:(NSString *)prompt
                 withError:(NSError * _Nullable __autoreleasing *)error{
    NSData *data = [self fetchDataForKey:key
                                  isSync:NO
                             accessGroup:nil
                      useOperationPrompt:prompt
                               withError:error];
    return [data dr_utf8String];
}

- (NSString *)syncStringForKey:(NSString *)key
                   accessGroup:(NSString *)accessGroup
                     withError:(NSError * _Nullable __autoreleasing *)error{
    NSData *data = [self fetchDataForKey:key
                                  isSync:YES
                             accessGroup:accessGroup
                      useOperationPrompt:nil
                               withError:error];
    return [data dr_utf8String];
}

#pragma mark - private

- (id)itemClassValue{
    switch (_itemClass) {
        case DRKeyChainStoreItemClassGenericPassword:
            return (__bridge id)kSecClassGenericPassword;
        case DRKeyChainStoreItemClassInternetPassword:
            return (__bridge id)kSecClassInternetPassword;
        default:
            return nil;
    }
}

- (id)protocolTypeValue{
    switch (_protocolType) {
        case DRKeyChainStoreProtocolTypeFTP:
            return (__bridge id)kSecAttrProtocolFTP;
        case DRKeyChainStoreProtocolTypeFTPAccount:
            return (__bridge id)kSecAttrProtocolFTPAccount;
        case DRKeyChainStoreProtocolTypeHTTP:
            return (__bridge id)kSecAttrProtocolHTTP;
        case DRKeyChainStoreProtocolTypeIRC:
            return (__bridge id)kSecAttrProtocolIRC;
        case DRKeyChainStoreProtocolTypeNNTP:
            return (__bridge id)kSecAttrProtocolNNTP;
        case DRKeyChainStoreProtocolTypePOP3:
            return (__bridge id)kSecAttrProtocolPOP3;
        case DRKeyChainStoreProtocolTypeSMTP:
            return (__bridge id)kSecAttrProtocolSMTP;
        case DRKeyChainStoreProtocolTypeSOCKS:
            return (__bridge id)kSecAttrProtocolSOCKS;
        case DRKeyChainStoreProtocolTypeIMAP:
            return (__bridge id)kSecAttrProtocolIMAP;
        case DRKeyChainStoreProtocolTypeLDAP:
            return (__bridge id)kSecAttrProtocolLDAP;
        case DRKeyChainStoreProtocolTypeAppleTalk:
            return (__bridge id)kSecAttrProtocolAppleTalk;
        case DRKeyChainStoreProtocolTypeAFP:
            return (__bridge id)kSecAttrProtocolAFP;
        case DRKeyChainStoreProtocolTypeTelnet:
            return (__bridge id)kSecAttrProtocolTelnet;
        case DRKeyChainStoreProtocolTypeSSH:
            return (__bridge id)kSecAttrProtocolSSH;
        case DRKeyChainStoreProtocolTypeFTPS:
            return (__bridge id)kSecAttrProtocolFTPS;
        case DRKeyChainStoreProtocolTypeHTTPS:
            return (__bridge id)kSecAttrProtocolHTTPS;
        case DRKeyChainStoreProtocolTypeHTTPProxy:
            return (__bridge id)kSecAttrProtocolHTTPProxy;
        case DRKeyChainStoreProtocolTypeHTTPSProxy:
            return (__bridge id)kSecAttrProtocolHTTPSProxy;
        case DRKeyChainStoreProtocolTypeFTPProxy:
            return (__bridge id)kSecAttrProtocolFTPProxy;
        case DRKeyChainStoreProtocolTypeSMB:
            return (__bridge id)kSecAttrProtocolSMB;
        case DRKeyChainStoreProtocolTypeRTSP:
            return (__bridge id)kSecAttrProtocolRTSP;
        case DRKeyChainStoreProtocolTypeRTSPProxy:
            return (__bridge id)kSecAttrProtocolRTSPProxy;
        case DRKeyChainStoreProtocolTypeDAAP:
            return (__bridge id)kSecAttrProtocolDAAP;
        case DRKeyChainStoreProtocolTypeEPPC:
            return (__bridge id)kSecAttrProtocolEPPC;
        case DRKeyChainStoreProtocolTypeNNTPS:
            return (__bridge id)kSecAttrProtocolNNTPS;
        case DRKeyChainStoreProtocolTypeLDAPS:
            return (__bridge id)kSecAttrProtocolLDAPS;
        case DRKeyChainStoreProtocolTypeTelnetS:
            return (__bridge id)kSecAttrProtocolTelnetS;
        case DRKeyChainStoreProtocolTypeIRCS:
            return (__bridge id)kSecAttrProtocolIRCS;
        case DRKeyChainStoreProtocolTypePOP3S:
            return (__bridge id)kSecAttrProtocolPOP3S;
        default:
            return nil;
    }
}

- (id)authTypeValue{
    switch (_authType) {
        case DRKeyChainStoreAuthTypeNTLM:
            return (__bridge id)kSecAttrAuthenticationTypeNTLM;
        case DRKeyChainStoreAuthTypeMSN:
            return (__bridge id)kSecAttrAuthenticationTypeMSN;
        case DRKeyChainStoreAuthTypeDPA:
            return (__bridge id)kSecAttrAuthenticationTypeDPA;
        case DRKeyChainStoreAuthTypeRPA:
            return (__bridge id)kSecAttrAuthenticationTypeRPA;
        case DRKeyChainStoreAuthTypeHTTPBasic:
            return (__bridge id)kSecAttrAuthenticationTypeHTTPBasic;
        case DRKeyChainStoreAuthTypeHTTPDigest:
            return (__bridge id)kSecAttrAuthenticationTypeHTTPDigest;
        case DRKeyChainStoreAuthTypeHTMLForm:
            return (__bridge id)kSecAttrAuthenticationTypeHTMLForm;
        case DRKeyChainStoreAuthTypeDefault:
            return (__bridge id)kSecAttrAuthenticationTypeDefault;
        default:
            return nil;
    }
}

- (NSMutableDictionary *)query{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[(__bridge id)kSecClass] = [self itemClassValue];
    if (_itemClass == DRKeyChainStoreItemClassGenericPassword) {
        dic[(__bridge id)kSecAttrService] = _service;
    }
    if (_itemClass == DRKeyChainStoreItemClassInternetPassword) {
        dic[(__bridge id)kSecAttrServer] = _server.host;
        dic[(__bridge id)kSecAttrPort] = _server.port;
        dic[(__bridge id)kSecAttrProtocol] = [self protocolTypeValue];
        dic[(__bridge id)kSecAttrAuthenticationType] = [self authTypeValue];
        if (_server.path.length) {
            dic[(__bridge id)kSecAttrPath] = _server.path;
        }
    }
    return dic;
}

- (void)setError:(NSError **)error code:(NSInteger)code message:(NSString *)msg{
    if (error == NULL) return;
    NSError *err = DRCreateError(kDRKeychainErrorDomain, code, msg);
    DRSetError(error, err);
}

- (id)accessControlValueWithAccessible:(DRKeyChainStoreAccessibility)accessible
                  authenticationPolicy:(DRKeyChainStoreAuthenticationPolicy)policy
                             withError:(NSError **)error{
    if (@available(iOS 8.0, *)) {
        CFTypeRef protection = (__bridge CFTypeRef)DRAccessibilityValue(accessible);
        SecAccessControlCreateFlags flags = DRKeychainAuthPolicyFlags(policy);
        if (flags > 0 && protection) {
            CFErrorRef securityError = NULL;
            SecAccessControlRef accessControl = SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                                                                protection,
                                                                                flags,
                                                                                &securityError);
            if (securityError) {
                NSError *err = (__bridge_transfer NSError *)securityError;
                DRSetError(error, err);
                CFRelease(accessControl);
                return nil;
            }
            if (!accessControl) {
                // 未知错误
                NSError *err = DRCreateError(kDRKeychainErrorDomain, -9999, @"Unexpected error has occurred.");
                DRSetError(error, err);
                return nil;
            }
            return (__bridge_transfer id)accessControl;
        }
    }
    return nil;
}

@end
