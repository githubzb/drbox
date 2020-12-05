//
//  NSDate+drbox.h
//  drbox
//
//  Created by dr.box on 2020/8/13.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (drbox)

/// 年
@property (nonatomic, readonly) NSInteger dr_year;
/// 月(（-12）
@property (nonatomic, readonly) NSInteger dr_month;
/// 日（1-31）
@property (nonatomic, readonly) NSInteger dr_day;
/// 时（0-23）
@property (nonatomic, readonly) NSInteger dr_hour;
/// 分（0-59）
@property (nonatomic, readonly) NSInteger dr_minute;
/// 秒（0-59）
@property (nonatomic, readonly) NSInteger dr_second;
/// 纳秒
@property (nonatomic, readonly) NSInteger dr_nanosecond;
/// 星期几（默认：以星期日为一周的第一天）
@property (nonatomic, readonly) NSInteger dr_weekday;
/// 星期序号（一个月当中的周的序号，第一个周下标为：0）
@property (nonatomic, readonly) NSInteger dr_weekdayOrdinal;
/// 一个月的第几周
@property (nonatomic, readonly) NSInteger dr_weekOfMonth;
/// 一年的第几周
@property (nonatomic, readonly) NSInteger dr_weekOfYear;
@property (nonatomic, readonly) NSInteger dr_yearForWeekOfYear;
@property (nonatomic, readonly) NSInteger dr_quarter;
/// 该月是否为闰月
@property (nonatomic, readonly) BOOL dr_isLeapMonth;
/// 该年是否为闰年
@property (nonatomic, readonly) BOOL dr_isLeapYear;
/// 该日期是否为今天
@property (nonatomic, readonly) BOOL dr_isToday;
/// 该日期是否为昨天
@property (nonatomic, readonly) BOOL dr_isYesterday;


/// 获取当前日期years年后的日期
- (nullable NSDate *)dr_dateByAddingYears:(NSInteger)years;

/// 获取当前日期months个月后的日期
- (nullable NSDate *)dr_dateByAddingMonths:(NSInteger)months;

/// 获取当前日期weeks个周后的日期
- (nullable NSDate *)dr_dateByAddingWeeks:(NSInteger)weeks;

/// 获取当前日期days天后的日期
- (nullable NSDate *)dr_dateByAddingDays:(NSInteger)days;

/// 获取当前日期hours个小时后的日期
- (nullable NSDate *)dr_dateByAddingHours:(NSInteger)hours;

/// 获取当前日期minutes个分钟后的日期
- (nullable NSDate *)dr_dateByAddingMinutes:(NSInteger)minutes;

/// 获取当前日期seconds秒后的日期
- (nullable NSDate *)dr_dateByAddingSeconds:(NSInteger)seconds;


/**
 dateFormat函数语法
 G 年代标志符
 y 年
 M 月
 d 日
 h 时 在上午或下午 (1~12)
 H 时 在一天中 (0~23)
 m 分
 s 秒
 S 毫秒
 E 星期
 D 一年中的第几天
 F 一月中第几个星期几
 w 一年中第几个星期
 W 一月中第几个星期
 a 上午 / 下午 标记符
 k 时 在一天中 (1~24)
 K 时 在上午或下午 (0~11)
 z 时区
 */

/// 获取当前日期的指定格式的字符串
- (nullable NSString *)dr_stringWithFormat:(NSString *)format;

/// 获取当前日期的指定格式的字符串（可以设置时区和地理位置）
- (nullable NSString *)dr_stringWithFormat:(NSString *)format
                                  timeZone:(nullable NSTimeZone *)timeZone
                                    locale:(nullable NSLocale *)locale;

/// 获取当前日期的 ISO8601标准的字符串；例如：2020-08-13T10:25:06+0800
- (nullable NSString *)dr_stringWithISOFormat;

/// 根据时间字符串和指定的格式，初始化date对象
+ (nullable NSDate *)dr_dateWithString:(NSString *)dateString format:(NSString *)format;

/// 根据时间字符串，初始化date对象
+ (nullable NSDate *)dr_dateWithString:(NSString *)dateString;
/// 根据时间字符串，初始化date对象
+ (nullable NSDate *)dr_dateWithString:(NSString *)dateString
                              timeZone:(nullable NSTimeZone *)timeZone
                                locale:(nullable NSLocale *)locale;

/// 根据时间字符串和指定的格式，初始化date对象（可以设置时区和地理位置）
+ (nullable NSDate *)dr_dateWithString:(NSString *)dateString
                                format:(NSString *)format
                              timeZone:(nullable NSTimeZone *)timeZone
                                locale:(nullable NSLocale *)locale;
/// 根据ISO8601标准的日期字符串，初始化date对象
+ (nullable NSDate *)dr_dateWithISOFormatString:(NSString *)dateString;

/// 获取当前日期的格式化字符串，格式为：yyyy-MM-dd HH:mm:ss
- (nullable NSString *)dr_yyyy_MM_dd_HH_mm_ss;

/// 获取当前日期的格式化字符串，格式为：yyyy-MM-dd
- (nullable NSString *)dr_yyyy_MM_dd;


///// 公历转农历日期
//- (NSDate *)dr_convertLunar;
///// 农历转公历日期
//- (NSDate *)dr_convertSolar;

@end

NS_ASSUME_NONNULL_END
