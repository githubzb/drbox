//
//  DRKeyChainsViewController.m
//  drbox
//
//  Created by dr.box on 2020/9/17.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DRKeyChainsViewController.h"
#import "Drbox.h"

@interface DRKeyChainsViewController ()

@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *accessGroup;
@property (nonatomic, strong) DRKeyChainStore *genericKeyChain;
@property (nonatomic, strong) DRKeyChainStore *internetKeyChain;

@end

@implementation DRKeyChainsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *service = @"com.drbox.keychain.test";
    self.accessGroup = @"P3U8RBA76L.com.zb.drbox.share";
    self.key = @"drbox";
    
    self.genericKeyChain = [[DRKeyChainStore alloc] initWithService:service];
    self.internetKeyChain = [[DRKeyChainStore alloc] initWithServer:[NSURL URLWithString:@"https://www.baidu.com/user/login"]
                                                       protocolType:DRKeyChainStoreProtocolTypeHTTPS
                                                           authType:DRKeyChainStoreAuthTypeHTTPBasic];
    
//    [self testGenericOne];
//    [self testGenericTwo];
//    [self testGenericThree];
    
    
//    [self testInternetOne];
//    [self testInternetTwo];
    [self testInternetThree];
}

// 测试非授权，不同步
- (void)testGenericOne{
    NSData *data = [@"test save data(not sync)" dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    [_genericKeyChain setData:data
                       forKey:_key
                    withError:&error];
    if (error) {
        NSLog(@"not sync添加失败：%@", error);
    }else{
        NSLog(@"not sync添加成功");
        NSData *d = [_genericKeyChain fetchDataForKey:_key
                                               isSync:NO
                                          accessGroup:nil
                                   useOperationPrompt:nil
                                            withError:&error];
        if (error) {
            NSLog(@"not sync查询失败: %@", error);
        }else{
            NSLog(@"not sync查询成功: %@", [d dr_utf8String]);
        }
        error = nil;
        NSArray *arr = [_genericKeyChain fetchAllDataSync:NO
                                              accessGroup:nil
                                       useOperationPrompt:nil
                                                withError:&error];
        if (error) {
            NSLog(@"not sync查询all失败: %@", error);
        }else{
            NSMutableArray *items = [NSMutableArray array];
            for (NSData *data in arr) {
                [items addObject:[data dr_utf8String]];
            }
            NSLog(@"not sync查询all成功：%@", items);
        }

        // 更新
        error = nil;
        NSData *updateData = [@"test update data(not sync)" dataUsingEncoding:NSUTF8StringEncoding];
        [_genericKeyChain setData:updateData
                           forKey:_key
                        withError:&error];
        if (error) {
            NSLog(@"not sync 更新失败：%@", error);
        }else{
            NSData *res = [_genericKeyChain fetchDataForKey:_key
                                                     isSync:NO
                                                accessGroup:nil
                                         useOperationPrompt:nil
                                                  withError:&error];
            if (error) {
                NSLog(@"not sync 更新成功，再次查询失败：%@", error);
            }else{
                NSLog(@"not sync 更新成功，再次查询结果：%@", [res dr_utf8String]);
            }
        }

        // 判断是否包含
        error = nil;
        if ([_genericKeyChain containsForKey:_key
                                      isSync:NO
                                 accessGroup:nil
                          useOperationPrompt:nil withError:&error]) {
            NSLog(@"not sync 包含key: %@", _key);
        }else{
            if (error) {
                NSLog(@"not sync 判断包含与否失败：%@", error);
            }else{
                NSLog(@"not sync 不包含key：%@", _key);
            }
        }

        // 删除
        error = nil;
        [_genericKeyChain removeDataForkey:_key
                                    isSync:NO
                               accessGroup:nil withError:&error];
        if (error) {
            NSLog(@"not sync 删除失败：%@", error);
        }else{
            if ([_genericKeyChain containsForKey:_key
                                          isSync:NO
                                     accessGroup:nil
                              useOperationPrompt:nil withError:&error]) {
                NSLog(@"not sync 删除成功，但key：%@，依然存在", _key);
            }else{
                if (error) {
                    NSLog(@"not sync 删除成功，查询是否存在出错：%@", error);
                }else{
                    NSLog(@"not sync 删除成功,key：%@，已不存在", _key);
                }
            }
        }
    }
}

// 测试同步
- (void)testGenericTwo{
    NSData *data = [@"test save data(sync)" dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    [_genericKeyChain setSyncData:data
                           forKey:_key
                      accessGroup:_accessGroup
                        withError:&error];
    if (error) {
        NSLog(@"sync 保存失败：%@", error);
    }else{
        NSLog(@"sync 保存成功");
        
        // 查询
        NSData *d = [_genericKeyChain fetchDataForKey:_key
                                               isSync:YES
                                          accessGroup:_accessGroup
                                   useOperationPrompt:nil
                                            withError:&error];
        if (error) {
            NSLog(@"sync 查询失败：%@", error);
        }else{
            NSLog(@"sync 查询成功：%@", [d dr_utf8String]);
        }
        
        // 查询全部
        error = nil;
        NSArray *arr = [_genericKeyChain fetchAllDataSync:YES
                                              accessGroup:_accessGroup
                                       useOperationPrompt:nil
                                                withError:&error];
        if (error) {
            NSLog(@"sync 查询all失败：%@", error);
        }else{
            NSMutableArray *items = [NSMutableArray array];
            for (NSData *data in arr) {
                [items addObject:[data dr_utf8String]];
            }
            NSLog(@"sync 查询all成功：%@", items);
        }
        
        // 更新
        error = nil;
        NSData *updateData = [@"test update data(sync)" dataUsingEncoding:NSUTF8StringEncoding];
        [_genericKeyChain setSyncData:updateData
                               forKey:_key
                          accessGroup:_accessGroup
                            withError:&error];
        if (error) {
            NSLog(@"sync 更新失败：%@", error);
        }else{
            
            NSData *res = [_genericKeyChain fetchDataForKey:_key
                                                     isSync:YES
                                                accessGroup:_accessGroup
                                         useOperationPrompt:nil
                                                  withError:&error];
            if (error) {
                NSLog(@"sync 更新成功，再次查询失败：%@", error);
            }else{
                NSLog(@"sync 更新成功：%@", [res dr_utf8String]);
            }
        }
        
        // 是否包含
        error = nil;
        if ([_genericKeyChain containsForKey:_key
                                      isSync:YES
                                 accessGroup:_accessGroup
                          useOperationPrompt:nil
                                   withError:&error]) {
            NSLog(@"sync 包含key:%@", _key);
        }else{
            if (error) {
                NSLog(@"sync 判断是否包含key:%@失败：%@", _key, error);
            }else{
                NSLog(@"sync 不包含key:%@", _key);
            }
        }
        
        // 删除
        error = nil;
        [_genericKeyChain removeDataForkey:_key
                                    isSync:YES
                               accessGroup:_accessGroup
                                 withError:&error];
        if (error) {
            NSLog(@"sync 删除失败：%@", error);
        }else{
            if ([_genericKeyChain containsForKey:_key
                                          isSync:YES
                                     accessGroup:_accessGroup
                              useOperationPrompt:nil
                                       withError:&error]) {
                NSLog(@"sync 删除成功，包含key：%@", _key);
            }else{
                if (error) {
                    NSLog(@"sync 删除成功，判断包含key：%@失败:%@", _key, error);
                }else{
                    NSLog(@"sync 删除成功，不包含key：%@", _key);
                }
            }
        }
    }
}

// 测试授权，不同步
- (void)testGenericThree{
    NSData *data = [@"test save data(not sync, auth)" dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    [_genericKeyChain setData:data
                       forKey:_key
                    useAuthUI:YES
           useOperationPrompt:@"请设置一个密码，用于保护数据"
    useDataProtectionKeychain:YES
                   accessible:DRKeyChainStoreAccessibilityAfterFirstUnlock
         authenticationPolicy:DRKeyChainStoreAuthenticationPolicyApplicationPassword
                    withError:&error];
    if (error) {
        NSLog(@"auth 保存失败：%@", error);
    }else{
        NSLog(@"auth 保存成功");
        
        // 查询
        NSData *d = [_genericKeyChain fetchDataForKey:_key
                                               isSync:NO
                                          accessGroup:nil
                                   useOperationPrompt:@"请输入您设置的密码"
                                            withError:&error];
        if (error) {
            NSLog(@"auth 保存成功，查询失败：%@", error);
        }else{
            NSLog(@"auth 保存成功，查询成功：%@", [d dr_utf8String]);
        }
        
        // 查询all
        error = nil;
        NSArray *arr = [_genericKeyChain fetchAllDataSync:NO
                                              accessGroup:nil
                                       useOperationPrompt:@"请输入您设置的密码"
                                                withError:&error];
        if (error) {
            NSLog(@"auth 保存成功，查询all失败：%@", error);
        }else{
            NSMutableArray *items = [NSMutableArray array];
            for (NSData *data in arr) {
                [items addObject:[data dr_utf8String]];
            }
            NSLog(@"auth 保存成功，查询all成功：%@", items);
        }
        
        // 判断是否包含
        error = nil;
        if ([_genericKeyChain containsForKey:_key
                                      isSync:NO
                                 accessGroup:nil
                          useOperationPrompt:@"请输入您设置的密码"
                                   withError:&error]) {
            NSLog(@"auth 包含key：%@", _key);
        }else{
            if (error) {
                NSLog(@"auth 判断包含key：%@失败:%@", _key, error);
            }else{
                NSLog(@"auth 不包含key：%@", _key);
            }
        }
        
        // 更新
        NSData *updateData = [@"test update data(not sync, auth)" dataUsingEncoding:NSUTF8StringEncoding];
        error = nil;
        [_genericKeyChain setData:updateData
                           forKey:_key
                        useAuthUI:YES
               useOperationPrompt:@"更新需要输入你的密码"
        useDataProtectionKeychain:YES
                       accessible:DRKeyChainStoreAccessibilityAfterFirstUnlock
             authenticationPolicy:DRKeyChainStoreAuthenticationPolicyApplicationPassword
                        withError:&error];
        if (error) {
            NSLog(@"auth 更新失败：%@", error);
        }else{
            
            NSData *res = [_genericKeyChain fetchDataForKey:_key
                                                     isSync:NO
                                                accessGroup:nil
                                         useOperationPrompt:@"请输入您的密码，查询更新内容"
                                                  withError:&error];
            if (error) {
                NSLog(@"auth 更新失败：%@", error);
            }else{
                NSLog(@"auth 更新成功：%@", [res dr_utf8String]);
            }
        }
        
        // 删除
        error = nil;
        [_genericKeyChain removeDataForkey:_key
                                    isSync:NO
                               accessGroup:nil withError:&error];
        if (error) {
            NSLog(@"auth 删除失败：%@", error);
        }else{
            if ([_genericKeyChain containsForKey:_key
                                          isSync:NO
                                     accessGroup:nil
                              useOperationPrompt:@"请输入您设置的密码，用于判断是否删除成功"
                                       withError:&error]) {
                NSLog(@"auth 删除成功，包含key:%@", _key);
            }else{
                if (error) {
                    NSLog(@"auth 删除成功，判断包含key:%@失败:%@", _key, error);
                }else{
                    NSLog(@"auth 删除成功，不包含key:%@", _key);
                }
            }
        }
        
    }
}

// 测试非授权，不同步
- (void)testInternetOne{
    NSData *data = [@"test save internet data(not sync)" dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    [_internetKeyChain setData:data
                       forKey:_key
                    withError:&error];
    if (error) {
        NSLog(@"not sync添加失败：%@", error);
    }else{
        NSLog(@"not sync添加成功");
        NSData *d = [_internetKeyChain fetchDataForKey:_key
                                               isSync:NO
                                          accessGroup:nil
                                   useOperationPrompt:nil
                                            withError:&error];
        if (error) {
            NSLog(@"not sync查询失败: %@", error);
        }else{
            NSLog(@"not sync查询成功: %@", [d dr_utf8String]);
        }
        error = nil;
        NSArray *arr = [_internetKeyChain fetchAllDataSync:NO
                                              accessGroup:nil
                                       useOperationPrompt:nil
                                                withError:&error];
        if (error) {
            NSLog(@"not sync查询all失败: %@", error);
        }else{
            NSMutableArray *items = [NSMutableArray array];
            for (NSData *data in arr) {
                [items addObject:[data dr_utf8String]];
            }
            NSLog(@"not sync查询all成功：%@", items);
        }

        // 更新
        error = nil;
        NSData *updateData = [@"test update internet data(not sync)" dataUsingEncoding:NSUTF8StringEncoding];
        [_internetKeyChain setData:updateData
                           forKey:_key
                        withError:&error];
        if (error) {
            NSLog(@"not sync 更新失败：%@", error);
        }else{
            NSData *res = [_internetKeyChain fetchDataForKey:_key
                                                     isSync:NO
                                                accessGroup:nil
                                         useOperationPrompt:nil
                                                  withError:&error];
            if (error) {
                NSLog(@"not sync 更新成功，再次查询失败：%@", error);
            }else{
                NSLog(@"not sync 更新成功，再次查询结果：%@", [res dr_utf8String]);
            }
        }

        // 判断是否包含
        error = nil;
        if ([_internetKeyChain containsForKey:_key
                                      isSync:NO
                                 accessGroup:nil
                          useOperationPrompt:nil withError:&error]) {
            NSLog(@"not sync 包含key: %@", _key);
        }else{
            if (error) {
                NSLog(@"not sync 判断包含与否失败：%@", error);
            }else{
                NSLog(@"not sync 不包含key：%@", _key);
            }
        }

        // 删除
        error = nil;
        [_internetKeyChain removeDataForkey:_key
                                    isSync:NO
                               accessGroup:nil withError:&error];
        if (error) {
            NSLog(@"not sync 删除失败：%@", error);
        }else{
            if ([_internetKeyChain containsForKey:_key
                                          isSync:NO
                                     accessGroup:nil
                              useOperationPrompt:nil withError:&error]) {
                NSLog(@"not sync 删除成功，但key：%@，依然存在", _key);
            }else{
                if (error) {
                    NSLog(@"not sync 删除成功，查询是否存在出错：%@", error);
                }else{
                    NSLog(@"not sync 删除成功,key：%@，已不存在", _key);
                }
            }
        }
    }
}

// 测试同步
- (void)testInternetTwo{
    NSData *data = [@"test save internet data(sync)" dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    [_internetKeyChain setSyncData:data
                           forKey:_key
                      accessGroup:_accessGroup
                        withError:&error];
    if (error) {
        NSLog(@"sync 保存失败：%@", error);
    }else{
        NSLog(@"sync 保存成功");
        
        // 查询
        NSData *d = [_internetKeyChain fetchDataForKey:_key
                                               isSync:YES
                                          accessGroup:_accessGroup
                                   useOperationPrompt:nil
                                            withError:&error];
        if (error) {
            NSLog(@"sync 查询失败：%@", error);
        }else{
            NSLog(@"sync 查询成功：%@", [d dr_utf8String]);
        }
        
        // 查询全部
        error = nil;
        NSArray *arr = [_internetKeyChain fetchAllDataSync:YES
                                              accessGroup:_accessGroup
                                       useOperationPrompt:nil
                                                withError:&error];
        if (error) {
            NSLog(@"sync 查询all失败：%@", error);
        }else{
            NSMutableArray *items = [NSMutableArray array];
            for (NSData *data in arr) {
                [items addObject:[data dr_utf8String]];
            }
            NSLog(@"sync 查询all成功：%@", items);
        }
        
        // 更新
        error = nil;
        NSData *updateData = [@"test update internet data(sync)" dataUsingEncoding:NSUTF8StringEncoding];
        [_internetKeyChain setSyncData:updateData
                               forKey:_key
                          accessGroup:_accessGroup
                            withError:&error];
        if (error) {
            NSLog(@"sync 更新失败：%@", error);
        }else{
            
            NSData *res = [_internetKeyChain fetchDataForKey:_key
                                                     isSync:YES
                                                accessGroup:_accessGroup
                                         useOperationPrompt:nil
                                                  withError:&error];
            if (error) {
                NSLog(@"sync 更新成功，再次查询失败：%@", error);
            }else{
                NSLog(@"sync 更新成功：%@", [res dr_utf8String]);
            }
        }
        
        // 是否包含
        error = nil;
        if ([_internetKeyChain containsForKey:_key
                                      isSync:YES
                                 accessGroup:_accessGroup
                          useOperationPrompt:nil
                                   withError:&error]) {
            NSLog(@"sync 包含key:%@", _key);
        }else{
            if (error) {
                NSLog(@"sync 判断是否包含key:%@失败：%@", _key, error);
            }else{
                NSLog(@"sync 不包含key:%@", _key);
            }
        }
        
        // 删除
        error = nil;
        [_internetKeyChain removeDataForkey:_key
                                    isSync:YES
                               accessGroup:_accessGroup
                                 withError:&error];
        if (error) {
            NSLog(@"sync 删除失败：%@", error);
        }else{
            if ([_internetKeyChain containsForKey:_key
                                          isSync:YES
                                     accessGroup:_accessGroup
                              useOperationPrompt:nil
                                       withError:&error]) {
                NSLog(@"sync 删除成功，包含key：%@", _key);
            }else{
                if (error) {
                    NSLog(@"sync 删除成功，判断包含key：%@失败:%@", _key, error);
                }else{
                    NSLog(@"sync 删除成功，不包含key：%@", _key);
                }
            }
        }
    }
}

// 测试授权，不同步
- (void)testInternetThree{
    NSData *data = [@"test save internet data(not sync, auth)" dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    [_internetKeyChain setData:data
                       forKey:_key
                    useAuthUI:YES
           useOperationPrompt:@"请设置一个密码，用于保护数据"
    useDataProtectionKeychain:YES
                   accessible:DRKeyChainStoreAccessibilityAfterFirstUnlock
         authenticationPolicy:DRKeyChainStoreAuthenticationPolicyApplicationPassword
                    withError:&error];
    if (error) {
        NSLog(@"auth 保存失败：%@", error);
    }else{
        NSLog(@"auth 保存成功");
        
        // 查询
        NSData *d = [_internetKeyChain fetchDataForKey:_key
                                               isSync:NO
                                          accessGroup:nil
                                   useOperationPrompt:@"请输入您设置的密码,查询用"
                                            withError:&error];
        if (error) {
            NSLog(@"auth 保存成功，查询失败：%@", error);
        }else{
            NSLog(@"auth 保存成功，查询成功：%@", [d dr_utf8String]);
        }
        
        // 查询all
        error = nil;
        NSArray *arr = [_internetKeyChain fetchAllDataSync:NO
                                              accessGroup:nil
                                       useOperationPrompt:@"请输入您设置的密码,查询所有"
                                                withError:&error];
        if (error) {
            NSLog(@"auth 保存成功，查询all失败：%@", error);
        }else{
            NSMutableArray *items = [NSMutableArray array];
            for (NSData *data in arr) {
                [items addObject:[data dr_utf8String]];
            }
            NSLog(@"auth 保存成功，查询all成功：%@", items);
        }
        
        // 判断是否包含
        error = nil;
        if ([_internetKeyChain containsForKey:_key
                                      isSync:NO
                                 accessGroup:nil
                          useOperationPrompt:@"请输入您设置的密码,包含"
                                   withError:&error]) {
            NSLog(@"auth 包含key：%@", _key);
        }else{
            if (error) {
                NSLog(@"auth 判断包含key：%@失败:%@", _key, error);
            }else{
                NSLog(@"auth 不包含key：%@", _key);
            }
        }
        
        // 更新
        NSData *updateData = [@"test update data(not sync, auth)" dataUsingEncoding:NSUTF8StringEncoding];
        error = nil;
        [_internetKeyChain setData:updateData
                           forKey:_key
                        useAuthUI:YES
               useOperationPrompt:@"更新需要输入您的密码"
        useDataProtectionKeychain:YES
                       accessible:DRKeyChainStoreAccessibilityAfterFirstUnlock
             authenticationPolicy:DRKeyChainStoreAuthenticationPolicyApplicationPassword
                        withError:&error];
        if (error) {
            NSLog(@"auth 更新失败：%@", error);
        }else{
            
            NSData *res = [_internetKeyChain fetchDataForKey:_key
                                                     isSync:NO
                                                accessGroup:nil
                                         useOperationPrompt:@"请输入您的密码，查询更新内容"
                                                  withError:&error];
            if (error) {
                NSLog(@"auth 更新失败：%@", error);
            }else{
                NSLog(@"auth 更新成功：%@", [res dr_utf8String]);
            }
        }
        
        // 删除
        error = nil;
        [_internetKeyChain removeDataForkey:_key
                                    isSync:NO
                               accessGroup:nil withError:&error];
        if (error) {
            NSLog(@"auth 删除失败：%@", error);
        }else{
            if ([_internetKeyChain containsForKey:_key
                                          isSync:NO
                                     accessGroup:nil
                              useOperationPrompt:@"请输入您设置的密码，用于判断是否删除成功"
                                       withError:&error]) {
                NSLog(@"auth 删除成功，包含key:%@", _key);
            }else{
                if (error) {
                    NSLog(@"auth 删除成功，判断包含key:%@失败:%@", _key, error);
                }else{
                    NSLog(@"auth 删除成功，不包含key:%@", _key);
                }
            }
        }
        
    }
}

@end
