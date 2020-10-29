//
//  NSArray+drbox.m
//  drbox
//
//  Created by dr.box on 2020/7/21.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "NSArray+drbox.h"
#import "NSData+drbox.h"


@implementation NSArray (drbox)

+ (NSArray *)dr_arrayWithPlistData:(NSData *)plist{
    if (!plist) return nil;
    NSArray *arr = [NSPropertyListSerialization propertyListWithData:plist
                                                             options:NSPropertyListImmutable
                                                              format:nil
                                                               error:NULL];
    if ([arr isKindOfClass:[NSArray class]]) return arr;
    return nil;
}

- (NSData *)dr_plistData{
    return [NSPropertyListSerialization dataWithPropertyList:self
                                                      format:NSPropertyListBinaryFormat_v1_0
                                                     options:kNilOptions
                                                       error:NULL];
}
- (NSString *)dr_plistString{
    NSData *xmlData = [NSPropertyListSerialization dataWithPropertyList:self
                                                                 format:NSPropertyListXMLFormat_v1_0
                                                                options:kNilOptions
                                                                  error:NULL];
    if (xmlData) return [xmlData dr_utf8String];
    return nil;
}

- (id)dr_randomObject{
    if (self.count>0) {
        return self[arc4random_uniform((u_int32_t)self.count)];
    }
    return nil;
}

- (id)dr_objectAtIndex:(NSUInteger)index{
    return index < self.count ? self[index] : nil;
}

- (NSString *)dr_jsonString{
    if ([NSJSONSerialization isValidJSONObject:self]) {
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:0 error:&error];
        NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        if (!error) return json;
    }
    return nil;
}

- (NSString *)dr_jsonPrettyString{
    if ([NSJSONSerialization isValidJSONObject:self]) {
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
        NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        if (!error) return json;
    }
    return nil;
}

@end

@implementation NSMutableArray (drbox)

+ (NSMutableArray *)dr_arrayWithPlistData:(NSData *)plist{
    if (!plist) return nil;
    NSMutableArray *array = [NSPropertyListSerialization propertyListWithData:plist
                                                                      options:NSPropertyListMutableContainersAndLeaves
                                                                       format:nil
                                                                        error:NULL];
    if ([array isKindOfClass:[NSMutableArray class]]) return array;
    return nil;
}

- (void)dr_removeFirstObject{
    if (self.count>0){
        [self removeObjectAtIndex:0];
    }
}

- (id)dr_popFirstObject{
    id obj = nil;
    if (self.count>0) {
        obj = self.firstObject;
        [self dr_removeFirstObject];
    }
    return obj;
}

- (id)dr_popLastObject{
    id obj = nil;
    if (self.count>0) {
        obj = self.lastObject;
        [self removeLastObject];
    }
    return obj;
}

- (void)dr_reverse{
    NSUInteger count = self.count;
    int mid = floor(count / 2.0);
    for (NSUInteger i = 0; i < mid; i++) {
        [self exchangeObjectAtIndex:i withObjectAtIndex:(count - (i + 1))];
    }
}

- (void)dr_shuffle{
    for (NSUInteger i = self.count; i > 1; i--) {
        [self exchangeObjectAtIndex:(i - 1)
                  withObjectAtIndex:arc4random_uniform((u_int32_t)i)];
    }
}

@end
