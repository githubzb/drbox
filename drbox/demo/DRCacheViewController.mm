//
//  DRCacheViewController.m
//  drbox
//
//  Created by dr.box on 2020/8/9.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DRCacheViewController.h"
#import "Drbox.h"

@interface DRCacheViewController (){
    DRCache *_cache;
}

@end

@implementation DRCacheViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _cache = [DRCache cacheWithName:@"com.drbox.cache"];
    _cache.diskCache.ageLimit = 30;
    NSLog(@"cache disk path:%@", _cache.diskCache.path);
    
//    // 同步存储
//    for (int i=0; i<20; i++) {
//        NSString *key = [NSString stringWithFormat:@"key_%d", i];
//        NSData *data = [[NSString stringWithFormat:@"datadatadata%d", i] dataUsingEncoding:NSUTF8StringEncoding];
//        [_cache setObject:data forKey:key];
//    }
//
//    // 异步存储
//    for (int i=0; i<20; i++) {
//        NSString *key = [NSString stringWithFormat:@"key2_%d", i];
//        NSData *data = [[NSString stringWithFormat:@"2datadatadata%d", i] dataUsingEncoding:NSUTF8StringEncoding];
//        [_cache setObject:data forKey:key withBlock:^{
//            NSLog(@"----key2缓存完成");
//        }];
//    }
    
    NSData *data = (NSData *)[_cache objectForKey:@"key_5"];
    NSLog(@"key_5缓存的值：%@", [data dr_utf8String]);
}


@end
