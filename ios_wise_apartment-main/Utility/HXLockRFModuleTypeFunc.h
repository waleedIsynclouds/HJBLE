//
//  HXLockRFModuleTypeFunc.h
//  HXJBLESDKDemo
//
//  Created by JQ on 2023/12/29.
//  Copyright © 2023 JQ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HXJBLESDK/SHGlobalHeader.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXLockRFModuleTypeFunc : NSObject

+ (BOOL)isHXJNBIoTRFType:(kHXRFModuleType)rfType;

+ (BOOL)isHXJWiFiRFType:(kHXRFModuleType)rfType;

+ (BOOL)isCat1RFType:(kHXRFModuleType)rfType;

@end

NS_ASSUME_NONNULL_END
