//
//  NSDictionary+drbox.m
//  drbox
//
//  Created by dr.box on 2020/7/21.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "NSDictionary+drbox.h"
#import "NSData+drbox.h"
#import "DRDictionaryParser.h"


@implementation NSDictionary (drbox)

+ (NSDictionary *)dr_dictionaryWithPlistData:(NSData *)plist{
    if (!plist) return nil;
    NSDictionary *dictionary = [NSPropertyListSerialization propertyListWithData:plist
                                                                         options:NSPropertyListImmutable
                                                                          format:NULL
                                                                           error:NULL];
    if ([dictionary isKindOfClass:[NSDictionary class]]) return dictionary;
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

- (NSArray *)dr_allKeysSorted{
    return [[self allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

- (NSArray *)dr_allValuesSortedByKeys{
    NSArray *sortedKeys = [self dr_allKeysSorted];
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (id key in sortedKeys) {
        [arr addObject:self[key]];
    }
    return [arr copy];// 可变字典copy后，返回的是不可变字典
}

- (BOOL)dr_containsObjectForKey:(id)key{
    if (!key) return NO;
    return self[key] != nil;
}

- (NSString *)dr_jsonString{
    if ([NSJSONSerialization isValidJSONObject:self]) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:0 error:&error];
        NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        if (!error) return json;
    }
    return nil;
}

- (NSString *)dr_jsonPrettyString{
    if ([NSJSONSerialization isValidJSONObject:self]) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
        NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        if (!error) return json;
    }
    return nil;
}

- (NSDictionary *)dr_filter:(BOOL (^)(id _Nonnull, id _Nonnull))block{
    NSParameterAssert(block);
    if (!block) return @{};
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (block(key, obj)) {
            [dic setValue:obj forKey:key];
        }
    }];
    return [dic copy];
}

- (NSDictionary *)dr_map:(NSDictionary * _Nullable (^)(id _Nonnull, id _Nonnull))block{
    NSParameterAssert(block);
    if (!block) return @{};
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSDictionary *_dic = block(key, obj);
        if ([_dic isKindOfClass:[NSDictionary class]]) {
            [dic addEntriesFromDictionary:_dic];
        }
    }];
    return [dic copy];
}

- (NSDictionary *)dr_find:(BOOL (^)(id _Nonnull, id _Nonnull))block{
    NSParameterAssert(block);
    if (!block) return nil;
    __block NSDictionary *_dic = nil;
    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (block(key, obj)) {
            _dic = @{key: obj};
            *stop = YES;
        }
    }];
    return _dic;
}

+ (NSDictionary *)dr_dictionaryWithXMLData:(NSData *)xmlData{
    return [[[DRDictionaryParser alloc] init] dictionaryWithData:xmlData];
}

+ (NSDictionary *)dr_dictionaryWithXMLString:(NSString *)xmlString{
    return [[[DRDictionaryParser alloc] init] dictionaryWithString:xmlString];
}

+ (NSDictionary *)dr_dictionaryWithXMLFile:(NSString *)xmlFilePath{
    return [[[DRDictionaryParser alloc] init] dictionaryWithFile:xmlFilePath];
}

@end
