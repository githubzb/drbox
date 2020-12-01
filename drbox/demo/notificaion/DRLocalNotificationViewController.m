//
//  DRLocalNotificationViewController.m
//  drbox
//
//  Created by dr.box on 2020/11/8.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DRLocalNotificationViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface DRLocalNotificationViewController ()

@property (nonatomic, strong) AVPlayer *player;

@end

@implementation DRLocalNotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    UILocalNotification *notification = [[UILocalNotification alloc] init];
//    // 设置触发通知的时间. //alertTime间隔时间
//    NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:5];
//
//    notification.fireDate = fireDate;
//    // 时区
//    notification.timeZone = [NSTimeZone defaultTimeZone];
//    // 设置重复的间隔
//    notification.repeatInterval = kCFCalendarUnitSecond;
//
//    // 通知内容
//    notification.alertTitle = @"起床提醒";
//    notification.alertBody =  @"⏰大茶埠喊您蹭茶啦";
//    notification.applicationIconBadgeNumber = 0;
//    // 通知被触发时播放的声音
////    notification.soundName = @"sound_01.wav";
//
//    // ios8后，需要添加这个注册，才能得到授权
//    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
//        UIUserNotificationType type =  UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
//        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type
//                                                                                 categories:nil];
//        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
//        // 通知重复提示的单位，可以是天、周、月
//        notification.repeatInterval = 0;
//    } else {
//        // 通知重复提示的单位，可以是天、周、月
//        notification.repeatInterval = 0;
//    }

    // 执行通知注册
//    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
//    NSArray *arr = [[UIApplication sharedApplication] scheduledLocalNotifications];
//    for (UILocalNotification *notify in arr) {
//        NSLog(@"----title:%@", notify.alertTitle);
//    }
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"bg" withExtension:@"mp4"];
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
    AVPlayer *player = [[AVPlayer alloc] initWithPlayerItem:item];
    
    AVPlayerLayer *layer1 = [AVPlayerLayer playerLayerWithPlayer:player];
    AVPlayerLayer *layer2 = [AVPlayerLayer playerLayerWithPlayer:player];
    
    layer1.videoGravity = AVLayerVideoGravityResize;
    
    UIView *v1 = [UIView new];
    v1.frame = CGRectMake(30, 120, 220, 160);
    [self.view addSubview:v1];
    layer1.frame = v1.bounds;
    [v1.layer addSublayer:layer1];
    
    UIView *v2 = [UIView new];
    v2.frame = CGRectMake(30, 300, 220, 160);
    [self.view addSubview:v2];
    layer2.frame = v2.bounds;
    [v2.layer addSublayer:layer2];
    
    [player play];
    self.player = player;
    
    v1.backgroundColor = [UIColor redColor];
    v2.backgroundColor = [UIColor greenColor];
}

@end
