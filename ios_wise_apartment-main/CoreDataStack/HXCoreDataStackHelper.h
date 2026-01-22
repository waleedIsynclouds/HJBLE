//
//  HXCoreDataStackHelper.h
//  HXJBLESDKDemo
//
//  Created by JQ on 2019/5/28.
//  Copyright © 2019 JQ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HXJBLESDKDemo+CoreDataModel.h"

#import <HXJBLESDK/HXBLEDevice.h>
#import <HXJBLESDK/HXBLEDeviceStatus.h>
#import <HXJBLESDK/HXKeyModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXCoreDataStackHelper : NSObject

+ (void)saveDevice:(HXBLEDevice *)deviceObj;

+ (void)saveDeviceStatus:(HXBLEDeviceStatus *)deviceStatusObj;

+ (void)saveKey:(HXKeyModel *)keyObj;

+ (void)deleteDeviceWithLockMac:(NSString *)lockMac;

+ (void)deleteKeyWithLockMac:(NSString *)lockMac;

+ (void)deleteKeyWithLockMac:(NSString *)lockMac lockKeyId:(int)lockKeyId;

+ (NSArray<HXBLEDevice *> *)deviceList;

+ (HXBLEDevice *)deviceWithLockMac:(NSString *)lockMac;

+ (HXBLEDeviceStatus *)deviceStatusWithLockMac:(NSString *)lockMac;

+ (NSArray<HXKeyModel *> *)keyListWithLockMac:(NSString *)lockMac;

@end

NS_ASSUME_NONNULL_END
