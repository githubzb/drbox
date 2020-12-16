//
//  DRUserInfo.h
//  drbox
//
//  Created by DHY on 2020/12/5.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface Car : NSObject

@property (nonatomic, copy) NSString *name;

@end

@interface DRPeople : NSObject<DRModel>{
    
    NSString *_firstName;
    NSString *_secondName;
}

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, copy) NSDate *birthday;

@end

@interface DRJob : NSObject<DRModel>

@property (nonatomic, copy) NSString *company;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *post;

@end


@interface MySelfInfo : DRPeople

@property (nonatomic, strong) DRJob *job;
@property (nonatomic, copy) NSArray *hobbys;
@property (nonatomic, copy) NSURL *headerUrl;

@end

@interface DRAuthInfo : NSObject{
    NSString *_token;
    NSInteger _deadline;
}

- (BOOL)isLogin;

@end


@interface DRUserInfo : DRAuthInfo<DRModel>

@property (nonatomic, strong) MySelfInfo *myInfo;
@property (nonatomic, strong) Car *myCar;
@property (nonatomic, copy) NSDictionary<NSString *, DRPeople *> *familys;

@end

NS_ASSUME_NONNULL_END
