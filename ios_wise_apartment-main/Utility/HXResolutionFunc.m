//
//  HXResolutionFunc.m
//  HXJBLESDKDemo
//
//  Created by JQ on 2019/5/29.
//  Copyright © 2019 JQ. All rights reserved.
//

#import "HXResolutionFunc.h"
#import <HXJBLESDK/HXRecordAlarmModel.h>

@implementation HXResolutionFunc

+ (NSString *)keyNameWithType:(KSHKeyType)keyType
{
    NSString *name = @"";
    if (keyType == KSHKeyType_Fingerprint) {
        name = NSLocalizedString(@"Fingerprint", @"指纹");
    }else if (keyType == KSHKeyType_Password) {
        name = NSLocalizedString(@"Password", @"密码");
    }else if (keyType == KSHKeyType_Card) {
        name = NSLocalizedString(@"Card", @"卡片");
    }else if (keyType == KSHKeyType_RemoteControl) {
        name = NSLocalizedString(@"Remote control", @"遥控");
    }else if (keyType == KSHKeyType_Face) {
        name = NSLocalizedString(@"Localizable_Face", @"人脸");
    }
    else {
        name = NSLocalizedString(@"Unknown type", @"未知类型");
    }
    return name;
}

+ (NSString *)weeksString:(kSHWeek)weeks
{
    NSString *string = @"";
    if (weeks == (kSHWeek_sunday|kSHWeek_monday|kSHWeek_tuesday|kSHWeek_wednesday|kSHWeek_thursday|kSHWeek_friday|kSHWeek_saturday)) {
        string = NSLocalizedString(@"Everyday", @"每天");
    }else if (weeks == (kSHWeek_monday|kSHWeek_tuesday|kSHWeek_wednesday|kSHWeek_thursday|kSHWeek_friday)) {
        string = NSLocalizedString(@"Working day", @"工作日");
    }else if (weeks == (kSHWeek_sunday|kSHWeek_saturday)) {
        string = NSLocalizedString(@"Weekend", @"周末");
    }else {
        if ((weeks&kSHWeek_sunday) == kSHWeek_sunday) {
            string = [string stringByAppendingString:NSLocalizedString(@"Sun. ", @"周日 ")];
        }
        if ((weeks&kSHWeek_monday) == kSHWeek_monday) {
            string = [string stringByAppendingString:NSLocalizedString(@"Mon. ", @"周一 ")];
        }
        if ((weeks&kSHWeek_tuesday) == kSHWeek_tuesday) {
            string = [string stringByAppendingString:NSLocalizedString(@"Tue. ", @"周二 ")];
        }
        if ((weeks&kSHWeek_wednesday) == kSHWeek_wednesday) {
            string = [string stringByAppendingString:NSLocalizedString(@"Wed. ", @"周三 ")];
        }
        if ((weeks&kSHWeek_thursday) == kSHWeek_thursday) {
            string = [string stringByAppendingString:NSLocalizedString(@"Thur. ", @"周四 ")];
        }
        if ((weeks&kSHWeek_friday) == kSHWeek_friday) {
            string = [string stringByAppendingString:NSLocalizedString(@"Fri. ", @"周五 ")];
        }
        if ((weeks&kSHWeek_saturday) == kSHWeek_saturday) {
            string = [string stringByAppendingString:NSLocalizedString(@"Sat. ", @"周六 ")];
        }
    }
    return string;
}

+ (NSString *)hhmmFromMinute:(int)minute
{
    NSString *str = [NSString stringWithFormat:@"%02d:%02d",minute/60,minute%60];
    return str;
}

+ (NSString *)validNumberString:(int)validNumber
{
    if (validNumber == 255) {
        return NSLocalizedString(@"Unlimited times", @"无限次");
    }else {
        return @(validNumber).stringValue;
    }
}

+ (NSString *)timeFromTimestamp:(NSTimeInterval)timestamp
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSCalendar *calendar = [self currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *components = [calendar components:unitFlags fromDate:date];
    int year = (int)components.year;
    int month = (int)components.month;
    int day = (int)components.day;
    int hour = (int)components.hour;
    int minute = (int)components.minute;
    NSString *time = [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d",year, month, day, hour, minute];
    return time;
}

+ (NSCalendar *)currentCalendar {
    if ([NSCalendar respondsToSelector:@selector(calendarWithIdentifier:)]) {
        return [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    }
    return [NSCalendar currentCalendar];
}

+ (NSString *)alarmString:(HXRecordAlarmModel *)model
{
    NSString *tips;
    if (model.alarmType == 1) {
        tips = NSLocalizedString(@"Demolition alarm", @"强拆报警");
    }else if (model.alarmType == 2) {
        tips = NSLocalizedString(@"Illegal operation alarm, the system is locked", @"非法操作报警，系统已锁定");
    }else if (model.alarmType == 3) {
        tips = NSLocalizedString(@"Low battery alarm, please replace the battery in time", @"低电量报警，请及时更换电池");
    }else if (model.alarmType == 4) {
        tips = [NSString stringWithFormat:NSLocalizedString(@"Please note that the user holding the key %d was duressed to open the lock", @"请注意，持有钥匙%d的用户被胁迫开锁"), model.alarmLockKeyId];
    }else if (model.alarmType == 5) {
        tips = NSLocalizedString(@"Lock core alarm", @"撬锁芯报警");
    }else if (model.alarmType == 6) {
        tips = NSLocalizedString(@"Unclosed door alarm", @"未关门报警");
    }else if (model.alarmType == 7) {
        if (model.faultType == 0) {
            tips = NSLocalizedString(@"Fault alarm: button short circuit", @"故障报警：按键短路");
        }else if (model.faultType == 1) {
            tips = NSLocalizedString(@"Fault alarm: abnormal memory", @"故障报警：存储器异常");
        }else if (model.faultType == 2) {
            tips = NSLocalizedString(@"Fault alarm: abnormal touch chip", @"故障报警：触摸芯片异常");
        }else if (model.faultType == 3) {
            tips = NSLocalizedString(@"Fault alarm: abnormal low-voltage detection circuit", @"故障报警：低压检测电路异常");
        }else if (model.faultType == 4) {
            tips = NSLocalizedString(@"Fault alarm: the card reading circuit is abnormal", @"故障报警：读卡电路异常");
        }else if (model.faultType == 5) {
            tips = NSLocalizedString(@"Fault alarm: check card circuit abnormal", @"故障报警：检卡电路异常");
        }else if (model.faultType == 6) {
            tips = NSLocalizedString(@"Fault alarm: fingerprint communication abnormal", @"故障报警：指纹通讯异常");
        }else if (model.faultType == 7) {
            tips = NSLocalizedString(@"Failure alarm: RTC crystal oscillator circuit is abnormal", @"故障报警：RTC晶振电路异常");
        }
    }else {
        tips = NSLocalizedString(@"Abnormal alarm", @"异常报警");
    }
    return tips;
}

+ (NSString *)systemLanguageString:(int)value
{
    NSString *systemLanguage = nil;
    if (value == 1) {
        systemLanguage = NSLocalizedString(@"Simplified Chinese", @"简体中文");
    }else if (value == 2) {
        systemLanguage = NSLocalizedString(@"Traditional Chinese", @"繁体中文");
    }else if (value == 3) {
        systemLanguage = NSLocalizedString(@"English", @"英文");
    }else if (value == 4) {
        systemLanguage = NSLocalizedString(@"Vietnamese", @"越南文");
    }else if (value == 5) {
        systemLanguage = NSLocalizedString(@"Thai", @"泰文");
    }
    return systemLanguage;
}

@end
