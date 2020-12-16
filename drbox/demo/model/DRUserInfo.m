//
//  DRUserInfo.m
//  drbox
//
//  Created by DHY on 2020/12/5.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DRUserInfo.h"

@implementation Car

- (NSString *)description
{
    return [NSString stringWithFormat:@"{name: %@}", self.name];
}

@end

@implementation DRJob

- (NSString *)description
{
    return [NSString stringWithFormat:@"{company: %@, post: %@, address: %@}", _company, _post, _address];
}

+ (NSDictionary<NSString *,id> *)toModelKeyMapper{
    return @{
        @"company": @"job_company",
        @"post": @"job_post"
    };
}

@end

@implementation DRPeople

- (NSString *)name{
    return [NSString stringWithFormat:@"%@%@", _firstName, _secondName];
}

+ (NSDictionary<NSString *,id> *)toModelKeyMapper{
    return @{
        @"_firstName": @[@"name.first", @"full_name.first", @"first"],
        @"_secondName": @[@"name.second", @"full_name.second", @"second"]
    };
}

+ (NSDictionary<NSString *,NSString *> *)toDictionaryKeyMapper{
    return @{
        @"_firstName": @"first",
        @"_secondName": @"second"
    };
}

- (NSString *)description{
    NSMutableString *str = [NSMutableString string];
    [str appendString:@"{"];
    [str appendFormat:@"name: %@", self.name];
    [str appendFormat:@", age: %ld", self.age];
    [str appendFormat:@", birthday: %@", self.birthday];
    [str appendString:@"}"];
    return str;
}

@end

@implementation MySelfInfo

@end

@implementation DRAuthInfo

- (BOOL)isLogin{
    return _token.length>0;
}

@end

@implementation DRUserInfo

+ (NSDictionary<NSString *,id> *)toModelContainerInnerClassMapper{
    return @{@"familys": @"DRPeople"};
}

+ (NSDictionary<NSString *,id> *)toModelKeyMapper{
    return @{
        @"myInfo": @"userInfo",
        @"myCar": @"car",
        @"_token": @[@"tokenInfo.token", @"token"],
        @"_deadline": @[@"tokenInfo.deadline", @"deadline"]
    };
}

+ (NSDictionary<NSString *,NSString *> *)toDictionaryKeyMapper{
    return @{
        @"myInfo": @"userInfo",
        @"myCar": @"car",
        @"_token": @"token",
        @"_deadline": @"deadline"
    };
}

- (NSString *)description
{
    NSMutableString *str = [NSMutableString string];
    [str appendFormat:@"name: %@", self.myInfo.name];
    [str appendFormat:@", age: %ld", self.myInfo.age];
    [str appendFormat:@", birthday: %@", self.myInfo.birthday];
    [str appendFormat:@", job: %@", self.myInfo.job];
    [str appendFormat:@", hobbys: %@", self.myInfo.hobbys];
    [str appendFormat:@", headerUrl: %@", self.myInfo.headerUrl];
    
    [str appendFormat:@", myCar: %@", self.myCar];
    [str appendFormat:@", familys: %@", self.familys];
    
    [str appendFormat:@", token: %@", _token];
    [str appendFormat:@", deadline: %ld", _deadline];
    
    return str;
}

@end
