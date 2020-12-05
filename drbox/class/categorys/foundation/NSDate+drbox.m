//
//  NSDate+drbox.m
//  drbox
//
//  Created by dr.box on 2020/8/13.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "NSDate+drbox.h"
#import "NSString+drbox.h"

@implementation NSDate (drbox)

- (NSInteger)dr_year {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:self] year];
}

- (NSInteger)dr_month {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitMonth fromDate:self] month];
}

- (NSInteger)dr_day {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:self] day];
}

- (NSInteger)dr_hour {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitHour fromDate:self] hour];
}

- (NSInteger)dr_minute {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitMinute fromDate:self] minute];
}

- (NSInteger)dr_second {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitSecond fromDate:self] second];
}

- (NSInteger)dr_nanosecond {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitSecond fromDate:self] nanosecond];
}

- (NSInteger)dr_weekday {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitWeekday fromDate:self] weekday];
}

- (NSInteger)dr_weekdayOrdinal {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitWeekdayOrdinal fromDate:self] weekdayOrdinal];
}

- (NSInteger)dr_weekOfMonth {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitWeekOfMonth fromDate:self] weekOfMonth];
}

- (NSInteger)dr_weekOfYear {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitWeekOfYear fromDate:self] weekOfYear];
}

- (NSInteger)dr_yearForWeekOfYear {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitYearForWeekOfYear fromDate:self] yearForWeekOfYear];
}

- (NSInteger)dr_quarter {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitQuarter fromDate:self] quarter];
}

- (BOOL)dr_isLeapMonth {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitQuarter fromDate:self] isLeapMonth];
}

- (BOOL)dr_isLeapYear {
    NSUInteger year = self.dr_year;
    return ((year % 400 == 0) || ((year % 100 != 0) && (year % 4 == 0)));
}

- (BOOL)dr_isToday {
    if (fabs(self.timeIntervalSinceNow) >= 60 * 60 * 24) return NO;
    return [NSDate new].dr_day == self.dr_day;
}

- (BOOL)dr_isYesterday {
    NSDate *added = [self dr_dateByAddingDays:1];
    return [added dr_isToday];
}

- (NSDate *)dr_dateByAddingYears:(NSInteger)years {
    NSCalendar *calendar =  [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setYear:years];
    return [calendar dateByAddingComponents:components toDate:self options:0];
}

- (NSDate *)dr_dateByAddingMonths:(NSInteger)months {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setMonth:months];
    return [calendar dateByAddingComponents:components toDate:self options:0];
}

- (NSDate *)dr_dateByAddingWeeks:(NSInteger)weeks {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setWeekOfYear:weeks];
    return [calendar dateByAddingComponents:components toDate:self options:0];
}

- (NSDate *)dr_dateByAddingDays:(NSInteger)days {
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + 86400 * days;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *)dr_dateByAddingHours:(NSInteger)hours {
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + 3600 * hours;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *)dr_dateByAddingMinutes:(NSInteger)minutes {
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + 60 * minutes;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *)dr_dateByAddingSeconds:(NSInteger)seconds {
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + seconds;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSString *)dr_stringWithFormat:(NSString *)format{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    [formatter setLocale:[NSLocale currentLocale]];
    return [formatter stringFromDate:self];
}

- (NSString *)dr_stringWithFormat:(NSString *)format timeZone:(NSTimeZone *)timeZone locale:(NSLocale *)locale {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    if (timeZone) [formatter setTimeZone:timeZone];
    if (locale) [formatter setLocale:locale];
    return [formatter stringFromDate:self];
}

- (NSString *)dr_stringWithISOFormat {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
    });
    return [formatter stringFromDate:self];
}

+ (NSDate *)dr_dateWithString:(NSString *)dateString format:(NSString *)format {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    return [formatter dateFromString:dateString];
}

+ (NSDate *)dr_dateWithString:(NSString *)dateString{
    return [self dr_dateWithString:dateString timeZone:nil locale:nil];
}

+ (NSDate *)dr_dateWithString:(NSString *)dateString timeZone:(NSTimeZone *)timeZone locale:(NSLocale *)locale{
    typedef NSDate* (^DRNSDateParseBlock)(NSString *string);
    #define kParserNum 34
    static DRNSDateParseBlock blocks[kParserNum + 1] = {0};
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        {
            /*
             2014-01-20  // Google
             */
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter.dateFormat = @"yyyy-MM-dd";
            blocks[10] = ^(NSString *string) {
                if (timeZone) formatter.timeZone = timeZone;
                if (locale) formatter.locale = locale;
                return [formatter dateFromString:string];
            };
        }
        
        {
            /*
             2014-01-20 12:24:48
             2014-01-20T12:24:48   // Google
             2014-01-20 12:24:48.000
             2014-01-20T12:24:48.000
             */
            NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
            formatter1.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter1.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter1.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
            
            NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
            formatter2.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter2.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter2.dateFormat = @"yyyy-MM-dd HH:mm:ss";

            NSDateFormatter *formatter3 = [[NSDateFormatter alloc] init];
            formatter3.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter3.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter3.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS";

            NSDateFormatter *formatter4 = [[NSDateFormatter alloc] init];
            formatter4.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter4.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter4.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
            
            blocks[19] = ^(NSString *string) {
                if ([string characterAtIndex:10] == 'T') {
                    if (timeZone) formatter1.timeZone = timeZone;
                    if (locale) formatter1.locale = locale;
                    return [formatter1 dateFromString:string];
                } else {
                    if (timeZone) formatter2.timeZone = timeZone;
                    if (locale) formatter2.locale = locale;
                    return [formatter2 dateFromString:string];
                }
            };

            blocks[23] = ^(NSString *string) {
                if ([string characterAtIndex:10] == 'T') {
                    if (timeZone) formatter3.timeZone = timeZone;
                    if (locale) formatter3.locale = locale;
                    return [formatter3 dateFromString:string];
                } else {
                    if (timeZone) formatter4.timeZone = timeZone;
                    if (locale) formatter4.locale = locale;
                    return [formatter4 dateFromString:string];
                }
            };
        }
        
        {
            /*
             2014-01-20T12:24:48Z        // Github, Apple
             2014-01-20T12:24:48+0800    // Facebook
             2014-01-20T12:24:48+12:00   // Google
             2014-01-20T12:24:48.000Z
             2014-01-20T12:24:48.000+0800
             2014-01-20T12:24:48.000+12:00
             */
            NSDateFormatter *formatter = [NSDateFormatter new];
            formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";

            NSDateFormatter *formatter2 = [NSDateFormatter new];
            formatter2.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter2.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZ";

            blocks[20] = ^(NSString *string) {
                if (timeZone) formatter.timeZone = timeZone;
                if (locale) formatter.locale = locale;
                return [formatter dateFromString:string];
            };
            blocks[24] = ^(NSString *string) {
                if (timeZone) {formatter.timeZone = timeZone; formatter2.timeZone = timeZone;}
                if (locale) {formatter.locale = locale; formatter2.locale = locale;}
                return [formatter dateFromString:string]?: [formatter2 dateFromString:string];
            };
            blocks[25] = ^(NSString *string) {
                if (timeZone) formatter.timeZone = timeZone;
                if (locale) formatter.locale = locale;
                return [formatter dateFromString:string];
            };
            blocks[28] = ^(NSString *string) {
                if (timeZone) formatter2.timeZone = timeZone;
                if (locale) formatter2.locale = locale;
                return [formatter2 dateFromString:string];
            };
            blocks[29] = ^(NSString *string) {
                if (timeZone) formatter2.timeZone = timeZone;
                if (locale) formatter2.locale = locale;
                return [formatter2 dateFromString:string];
            };
        }
        
        {
            /*
             Fri Sep 04 00:12:21 +0800 2015 // Weibo, Twitter
             Fri Sep 04 00:12:21.000 +0800 2015
             */
            NSDateFormatter *formatter = [NSDateFormatter new];
            formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter.dateFormat = @"EEE MMM dd HH:mm:ss Z yyyy";

            NSDateFormatter *formatter2 = [NSDateFormatter new];
            formatter2.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter2.dateFormat = @"EEE MMM dd HH:mm:ss.SSS Z yyyy";

            blocks[30] = ^(NSString *string) {
                if (timeZone) formatter.timeZone = timeZone;
                if (locale) formatter.locale = locale;
                return [formatter dateFromString:string];
            };
            blocks[34] = ^(NSString *string) {
                if (timeZone) formatter2.timeZone = timeZone;
                if (locale) formatter2.locale = locale;
                return [formatter2 dateFromString:string];
            };
        }
    });
    if (!dateString) return nil;
    NSString *str = dateString.dr_trim;
    if (str.length == 16) {
//        2014-01-20 12:24
        str = [NSString stringWithFormat:@"%@:00", dateString];
        
    }else if (str.length == 13){
//        2014-01-20 12
        str = [NSString stringWithFormat:@"%@:00:00", dateString];
    }
    if (str.length > kParserNum) return nil;
    
    DRNSDateParseBlock parser = blocks[str.length];
    if (!parser) return nil;
    return parser(str);
    #undef kParserNum
}

+ (NSDate *)dr_dateWithString:(NSString *)dateString format:(NSString *)format timeZone:(NSTimeZone *)timeZone locale:(NSLocale *)locale {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    if (timeZone) [formatter setTimeZone:timeZone];
    if (locale) [formatter setLocale:locale];
    return [formatter dateFromString:dateString];
}

+ (NSDate *)dr_dateWithISOFormatString:(NSString *)dateString {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
    });
    return [formatter dateFromString:dateString];
}

- (NSString *)dr_yyyy_MM_dd_HH_mm_ss{
    return [self dr_stringWithFormat:@"yyyy-MM-dd HH:mm:ss"];
}

- (NSString *)dr_yyyy_MM_dd{
    return [self dr_stringWithFormat:@"yyyy-MM-dd"];
}

//- (NSDate *)dr_convertLunar{
//    // 实例化农历calendar
//    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];
//    NSDateFormatter *df = [[NSDateFormatter alloc] init];
//    df.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
//    df.dateStyle = NSDateFormatterFullStyle;
//    df.calendar = calendar;
//    NSString *lunarStr = [df stringFromDate:self];
//    NSInteger year = [[lunarStr substringToIndex:4] integerValue];
//    NSInteger month = [calendar component:NSCalendarUnitMonth fromDate:self];
//    NSInteger day = [calendar component:NSCalendarUnitDay fromDate:self];
//    NSInteger h = [calendar component:NSCalendarUnitHour fromDate:self];
//    NSInteger m = [calendar component:NSCalendarUnitMinute fromDate:self];
//    NSInteger s = [calendar component:NSCalendarUnitSecond fromDate:self];
//    NSString *str = [NSString stringWithFormat:@"%ld-%02ld-%02ld %02ld:%02ld:%02ld", year, month, day, h, m, s];
//    return [NSDate dr_dateWithString:str format:@"yyyy-MM-dd HH:mm:ss"];
//}
//
//- (NSDate *)dr_convertSolar{
//    // TODO: 待完善
//    CFAbsoluteTime startTime =CFAbsoluteTimeGetCurrent();
//    NSInteger year = [self dr_year];
//    NSInteger m = [self dr_month];
//    NSInteger d = [self dr_day];
//
//    NSDate *date = [self dr_dateByAddingDays:1];
//    NSDate *ld = [date dr_convertLunar];
//    while (ld.dr_year != year || ld.dr_month != m || ld.dr_day != d) {
//        if (ld.dr_month < m || ld.dr_year < year || ld.dr_day < d) {
//            date = [date dr_dateByAddingDays:1];
//        }else{
//            date = [date dr_dateByAddingDays:-1];
//        }
//        ld = [date dr_convertLunar];
//    }
//    CFAbsoluteTime linkTime = (CFAbsoluteTimeGetCurrent() - startTime);
//
//    NSLog(@"Linked in %f ms", linkTime *1000.0);
//    return date;
//}

@end
