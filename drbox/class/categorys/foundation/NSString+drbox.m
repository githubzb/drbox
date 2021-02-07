//
//  NSString+drbox.m
//  drbox
//
//  Created by dr.box on 2020/7/20.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "NSString+drbox.h"
#import "NSData+drbox.h"
#import "NSNumber+drbox.h"

@implementation NSString (drbox)

- (NSData *)dr_utf8Data{
    return [self dataUsingEncoding:NSUTF8StringEncoding];
}
- (NSString *)dr_md5String{
    return [[self dr_utf8Data] dr_md5String];
}
- (NSString *)dr_sha224String{
    return [[self dr_utf8Data] dr_sha224String];
}
- (NSString *)dr_sha256String{
    return [[self dr_utf8Data] dr_sha256String];
}
- (NSString *)dr_sha384String{
    return [[self dr_utf8Data] dr_sha384String];
}
- (NSString *)dr_sha512String{
    return [[self dr_utf8Data] dr_sha512String];
}
- (NSString *)dr_crc32String{
    return [[self dr_utf8Data] dr_crc32String];
}
- (NSString *)dr_hmacSHA224StringWithKey:(NSString *)key{
    return [[self dr_utf8Data] dr_hmacSHA224StringWithKey:key];
}
- (NSString *)dr_hmacSHA256StringWithKey:(NSString *)key{
    return [[self dr_utf8Data] dr_hmacSHA256StringWithKey:key];
}
- (NSString *)dr_hmacSHA384StringWithKey:(NSString *)key{
    return [[self dr_utf8Data] dr_hmacSHA384StringWithKey:key];
}
- (NSString *)dr_hmacSHA512StringWithKey:(NSString *)key{
    return [[self dr_utf8Data] dr_hmacSHA512StringWithKey:key];
}

- (NSString *)dr_base64EncodedString{
    return [[self dr_utf8Data] base64EncodedStringWithOptions:0];
}
- (NSString *)dr_base64DecodedString{
    return [[[NSData alloc] initWithBase64EncodedString:self
                                                options:0] dr_utf8String];
}

- (NSURL *)dr_URL{
    return [NSURL URLWithString:[[self dr_urlDecodedString] dr_urlQueryEncodedString]];
}

- (NSDictionary<NSString *,NSString *> *)dr_parameters{
    NSURLComponents *components = [NSURLComponents componentsWithString:[[self dr_urlDecodedString] dr_urlQueryEncodedString]];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    // percentEncodedQueryItems是保留Encoding的值
    [components.percentEncodedQueryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [dic setValue:obj.value forKey:obj.name];
    }];
    return [dic copy];
}

- (NSDictionary<NSString *,NSString *> *)dr_parametersForURLDecoding{
    NSURLComponents *components = [NSURLComponents componentsWithString:[[self dr_urlDecodedString] dr_urlQueryEncodedString]];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    // queryItems是非Encoding的值
    [components.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [dic setValue:obj.value forKey:obj.name];
    }];
    return [dic copy];
}

- (NSString *)dr_urlEncodedString{
    if ([self respondsToSelector:@selector(stringByAddingPercentEncodingWithAllowedCharacters:)]) {
        static NSString * const kAFCharactersGeneralDelimitersToEncode = @":#[]@"; // does not include "?" or "/" due to RFC 3986 - Section 3.4
        static NSString * const kAFCharactersSubDelimitersToEncode = @"!$&'()*+,;=";
            
        NSMutableCharacterSet * allowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
        [allowedCharacterSet removeCharactersInString:[kAFCharactersGeneralDelimitersToEncode stringByAppendingString:kAFCharactersSubDelimitersToEncode]];
        static NSUInteger const batchSize = 50;
        
        NSUInteger index = 0;
        NSMutableString *escaped = @"".mutableCopy;
        
        while (index < self.length) {
            NSUInteger length = MIN(self.length - index, batchSize);
            NSRange range = NSMakeRange(index, length);
            // To avoid breaking up character sequences such as 👴🏻👮🏽
            range = [self rangeOfComposedCharacterSequencesForRange:range];
            NSString *substring = [self substringWithRange:range];
            NSString *encoded = [substring stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
            [escaped appendString:encoded];
            
            index += range.length;
        }
        return [escaped copy];
    } else {
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        CFStringEncoding cfEncoding = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
        NSString *encoded = (__bridge_transfer NSString *)
        CFURLCreateStringByAddingPercentEscapes(
                                                kCFAllocatorDefault,
                                                (__bridge CFStringRef)self,
                                                NULL,
                                                CFSTR("!#$&'()*+,/:;=?@[]"),
                                                cfEncoding);
        return encoded;
    #pragma clang diagnostic pop
    }
}

- (NSString *)dr_urlQueryEncodedString{
    return [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

- (NSString *)dr_urlDecodedString{
    if ([self respondsToSelector:@selector(stringByRemovingPercentEncoding)]) {
        return [self stringByRemovingPercentEncoding];
    } else {
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        CFStringEncoding en = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
        NSString *decoded = [self stringByReplacingOccurrencesOfString:@"+"
                                                            withString:@" "];
        decoded = (__bridge_transfer NSString *)
        CFURLCreateStringByReplacingPercentEscapesUsingEncoding(
                                                                NULL,
                                                                (__bridge CFStringRef)decoded,
                                                                CFSTR(""),
                                                                en);
        return decoded;
    #pragma clang diagnostic pop
    }
}

- (id)dr_jsonObj{
    return [[self dr_utf8Data] dr_jsonObj];
}
- (NSString *)dr_trim{
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    return [self stringByTrimmingCharactersInSet:set];
}

- (CGSize)dr_sizeForFont:(UIFont *)font size:(CGSize)size mode:(NSLineBreakMode)lineBreakMode{
    CGSize result;
    if (!font) font = [UIFont systemFontOfSize:12];
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableDictionary *attr = [NSMutableDictionary new];
        attr[NSFontAttributeName] = font;
        if (lineBreakMode != NSLineBreakByWordWrapping) {
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            paragraphStyle.lineBreakMode = lineBreakMode;
            attr[NSParagraphStyleAttributeName] = paragraphStyle;
        }
        CGRect rect = [self boundingRectWithSize:size
                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                      attributes:attr context:nil];
        result = rect.size;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        result = [self sizeWithFont:font constrainedToSize:size lineBreakMode:lineBreakMode];
#pragma clang diagnostic pop
    }
    return result;
}

- (CGFloat)dr_widthForFont:(UIFont *)font{
    return [self dr_sizeForFont:font size:CGSizeMake(HUGE, HUGE) mode:NSLineBreakByWordWrapping].width;
}

- (CGFloat)dr_heightForFont:(UIFont *)font width:(CGFloat)width{
    return [self dr_sizeForFont:font size:CGSizeMake(width, HUGE) mode:NSLineBreakByWordWrapping].height;
}

- (BOOL)dr_matchesRegex:(NSString *)regex options:(NSRegularExpressionOptions)options{
    NSRegularExpression *pattern = [NSRegularExpression regularExpressionWithPattern:regex options:options error:NULL];
    if (!pattern) return NO;
    return ([pattern numberOfMatchesInString:self options:0 range:NSMakeRange(0, self.length)] > 0);
}

- (void)dr_enumerateRegexMatches:(NSString *)regex
                         options:(NSRegularExpressionOptions)options
                      usingBlock:(void (^)(NSString * _Nonnull, NSRange, BOOL * _Nonnull))block{
    if (regex.length == 0 || !block) return;
    NSRegularExpression *pattern = [NSRegularExpression regularExpressionWithPattern:regex options:options error:nil];
    if (!regex) return;
    [pattern enumerateMatchesInString:self options:kNilOptions range:NSMakeRange(0, self.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        block([self substringWithRange:result.range], result.range, stop);
    }];
}

- (NSString *)dr_stringByReplacingRegex:(NSString *)regex
                                options:(NSRegularExpressionOptions)options
                             withString:(NSString *)replacement{
    NSRegularExpression *pattern = [NSRegularExpression regularExpressionWithPattern:regex options:options error:nil];
    if (!pattern) return self;
    return [pattern stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, [self length]) withTemplate:replacement];
}

+ (NSString *)dr_uuidString{
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    return (__bridge_transfer NSString *)string;
}

- (BOOL)dr_containsString:(NSString *)string{
    if (!string) return NO;
    return [self rangeOfString:string].location != NSNotFound;
}

- (BOOL)rdr_containsCharacterSet:(NSCharacterSet *)set{
    if (!set) return NO;
    return [self rangeOfCharacterFromSet:set].location != NSNotFound;
}

- (NSNumber *)dr_numberValue{
    return [NSNumber dr_numberWithString:self];
}

@end
