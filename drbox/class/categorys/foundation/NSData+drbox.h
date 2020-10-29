//
//  NSData+drbox.h
//  drbox
//
//  Created by dr.box on 2020/7/20.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (drbox)

- (NSString *)dr_md5String;
- (NSData *)dr_md5Data;
- (NSString *)dr_sha224String;
- (NSData *)dr_sha224Data;
- (NSString *)dr_sha256String;
- (NSData *)dr_sha256Data;
- (NSString *)dr_sha384String;
- (NSData *)dr_sha384Data;
- (NSString *)dr_sha512String;
- (NSData *)dr_sha512Data;
- (NSString *)dr_hmacMD5StringWithKey:(NSString *)key;
- (NSData *)dr_hmacMD5DataWithKey:(NSString *)key;
- (NSString *)dr_hmacSHA224StringWithKey:(NSString *)key;
- (NSData *)dr_hmacSHA224DataWithKey:(NSString *)key;
- (NSString *)dr_hmacSHA256StringWithKey:(NSString *)key;
- (NSData *)dr_hmacSHA256DataWithKey:(NSString *)key;
- (NSString *)dr_hmacSHA384StringWithKey:(NSString *)key;
- (NSData *)dr_hmacSHA384DataWithKey:(NSString *)key;
- (NSString *)dr_hmacSHA512StringWithKey:(NSString *)key;
- (NSData *)dr_hmacSHA512DataWithKey:(NSString *)key;
- (NSString *)dr_crc32String;
- (uint32_t)dr_crc32;
/**
 AES256加密
 
 @param key   加密的AES key，长度为（16，24，32），字节数为（128，192，256）
 @param iv    加密的AES向量值，长度为（16），字节数为（128），如果不需要可以传nil
 @return    加密后的NSData，如果失败，返回nil
 */
- (nullable NSData *)dr_aes256EncryptWithKey:(NSData *)key iv:(nullable NSData *)iv;
/**
 AES256解密
 
 @param key   解密的AES key，长度为（16，24，32），字节数为（128，192，256）
 @param iv     解密的AES向量值，长度为（16），字节数为（128），如果不需要可以传nil
 @return    解密后的NSData，如果失败，返回nil
 */
- (nullable NSData *)dr_aes256DecryptWithkey:(NSData *)key iv:(nullable NSData *)iv;

- (nullable NSString *)dr_utf8String;
- (nullable NSString *)dr_hexString;
/**
 将hex字符串转成NSData
 
 @param hexString   hex字符串
 @return 成功：返回NSData，失败返回nil
 */
+ (nullable NSData *)dr_dataWithHexString:(NSString *)hexString;

/// 返回NSDictionary、NSArray对象
- (nullable id)dr_jsonObj;

/// gzip压缩数据
- (nullable NSData *)dr_gzipDeflate;
/// gzip解压数据
- (nullable NSData *)dr_gzipInflate;
/// zlib压缩数据
- (nullable NSData *)dr_zlibDeflate;
/// zlib解压数据
- (nullable NSData *)dr_zlibInflate;

@end

NS_ASSUME_NONNULL_END
