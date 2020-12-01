//
//  DRSandboxTool.h
//  drbox
//
//  Created by dr.box on 2020/11/8.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DRSandboxTool : NSObject

/// 沙盒主目录（即应用程序所在的当年目录）
@property (nonatomic, readonly, class) NSString *homePath;

/**
 沙盒Documents目录
 
 @discussion
 苹果建议将程序创建产生的文件以及应用浏览产生的文件数据保存在该目录下；iTunes 会同步此文件夹中的内容。
 */
@property (nonatomic, readonly, class) NSString *documentsPath;

/**
 沙盒Library目录
 
 @discussion
 存储程序的默认设置和其他状态信息。iTunes会备份此目录，但不包含其子目录caches.
 */
@property (nonatomic, readonly, class) NSString *libraryPath;

/**
 沙盒Library/caches目录
 
 @discussion
 存放缓存文件；iTunes不会备份此目录；保存应用程序再次启动过程中需要的信息。
 */
@property (nonatomic, readonly, class) NSString *cachesPath;

/**
 沙盒Library/Sounds目录
 
 @discussion
 存放推送铃声文件；在推送的时候，指定notification.soundName（文件名即可），即可播放铃声。
 有效的声音文件只能存在两个地方。一个是在main bundle下，另一个是在主程序用户目录的 Library/Sounds下。
 */
@property (nonatomic, readonly, class, nullable) NSString *notifySoundsPath;

/**
 沙盒tmp目录
 
 @discussion
 提供一个创建临时文件的的地方。在应用退出时，该目录下的文件将被删除;也可能在应用不运行时被删除。
 保存应用程序再次启动过程中不需要的信息。
 */
@property (nonatomic, readonly, class) NSString *tmpPath;

/// 小组件与app共享目录
+ (nullable NSString *)widgetSharePathWithGroupIdentifier:(NSString *)identifier;

/// 小组件与app共享目录
+ (nullable NSURL *)widgetShareURLWithGroupIdentifier:(NSString *)identifier;

/// 获取小组件与app共享的NSUserDefaults
+ (nullable NSUserDefaults *)widgetShareUserDefaultsWithGroupIdentifier:(NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
