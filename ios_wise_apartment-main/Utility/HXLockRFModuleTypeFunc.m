//
//  HXLockRFModuleTypeFunc.m
//  HXJBLESDKDemo
//
//  Created by JQ on 2023/12/29.
//  Copyright © 2023 JQ. All rights reserved.
//

#import "HXLockRFModuleTypeFunc.h"

@implementation HXLockRFModuleTypeFunc

+ (BOOL)isHXJNBIoTRFType:(kHXRFModuleType)rfType
{
    if (rfType == kHXRFModuleType_HXJNBDX ||
        rfType == kHXRFModuleType_HXJNBMQTT ||
        rfType == kHXRFModuleType_HXJNBLWM2M) {
        return YES;
    }
    return NO;
}

+ (BOOL)isHXJWiFiRFType:(kHXRFModuleType)rfType
{
    if (rfType == kHXRFModuleType_HXJWIFI ||
        rfType == kHXRFModuleType_HXJWIFIZJJX) {
        return YES;
    }
    return NO;
}

+ (BOOL)isCat1RFType:(kHXRFModuleType)rfType
{
    if (rfType == kHXRFModuleType_HXJCat1) {
        return YES;
    }
    return NO;
}

@end
