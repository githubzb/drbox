//
//  DRUserInfo.h
//  drbox
//
//  Created by DHY on 2020/12/5.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Car : NSObject

@property (nonatomic, copy) NSString *name;

@end

@interface DRBaseInfo : NSObject{
    NSInteger _age;
}

@property (nonatomic, copy) NSString *name;

@end


@interface DRUserInfo : DRBaseInfo{
    
    NSURL *headerUrl;
}

@property (nonatomic, strong) Car *car;
@property (nonatomic, copy) NSArray *myCars;

@end

NS_ASSUME_NONNULL_END
