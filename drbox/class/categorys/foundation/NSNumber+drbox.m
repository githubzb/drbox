//
//  NSNumber+drbox.m
//  drbox
//
//  Created by dr.box on 2020/7/21.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "NSNumber+drbox.h"
#import "NSString+drbox.h"

@implementation NSNumber (drbox)

+ (NSNumber *)dr_numberWithString:(NSString *)string{
    NSString *str = [[string dr_trim] lowercaseString];
    if (!str || !str.length) {
        return nil;
    }
    
    static NSCharacterSet *dot;
    static NSDictionary *dic;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dot = [NSCharacterSet characterSetWithRange:NSMakeRange('.', 1)];
        dic = @{@"TRUE" :   @(YES),
                @"True" :   @(YES),
                @"true" :   @(YES),
                @"FALSE" :  @(NO),
                @"False" :  @(NO),
                @"false" :  @(NO),
                @"YES" :    @(YES),
                @"Yes" :    @(YES),
                @"yes" :    @(YES),
                @"NO" :     @(NO),
                @"No" :     @(NO),
                @"no" :     @(NO),
                @"NIL" :    (id)kCFNull,
                @"Nil" :    (id)kCFNull,
                @"nil" :    (id)kCFNull,
                @"NULL" :   (id)kCFNull,
                @"Null" :   (id)kCFNull,
                @"null" :   (id)kCFNull,
                @"(NULL)" : (id)kCFNull,
                @"(Null)" : (id)kCFNull,
                @"(null)" : (id)kCFNull,
                @"<NULL>" : (id)kCFNull,
                @"<Null>" : (id)kCFNull,
                @"<null>" : (id)kCFNull};
    });
    id num = dic[str];
    if (num != nil) {
        if (num == (id)kCFNull) return nil;
        return num;
    }
    // 1.023 number
    if ([str dr_containsCharacterSet:dot]) {
        const char *cstring = str.UTF8String;
        if (!cstring) return nil;
        double num = atof(cstring);
        if (isnan(num) || isinf(num)) return nil;
        return @(num);
    }
    
    // hex number
    int sign = 0;
    if ([str hasPrefix:@"0x"]) sign = 1;
    else if ([str hasPrefix:@"-0x"]) sign = -1;
    if (sign != 0) {
        NSScanner *scan = [NSScanner scannerWithString:str];
        unsigned num = -1;
        BOOL suc = [scan scanHexInt:&num];
        if (suc)
            return [NSNumber numberWithLong:((long)num * sign)];
        else
            return nil;
    }
    
    const char *cstring = str.UTF8String;
    if (!cstring) return nil;
    return @(atoll(cstring));
}

@end
