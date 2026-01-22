//
//  HXResolutionFunc.h
//  HXJBLESDKDemo
//
//  Created by JQ on 2019/5/29.
//  Copyright © 2019 JQ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HXJBLESDK/JQBLEDefines.h>

NS_ASSUME_NONNULL_BEGIN

@class HXRecordAlarmModel;

@interface HXResolutionFunc : NSObject

+ (NSString *)keyNameWithType:(KSHKeyType)keyType;

+ (NSString *)weeksString:(kSHWeek)weeks;

+ (NSString *)hhmmFromMinute:(int)minute;

+ (NSString *)validNumberString:(int)validNumber;

+ (NSString *)timeFromTimestamp:(NSTimeInterval)timestamp;

+ (NSString *)alarmString:(HXRecordAlarmModel *)model;

+ (NSString *)systemLanguageString:(int)value;

@end

NS_ASSUME_NONNULL_END
