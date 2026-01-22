//
//  HXBLEUpgradeVC.h
//  HXJBLESDKDemo
//
//  Created by JQ on 2021/4/21.
//  Copyright © 2021 JQ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class HXBLEDevice;

@interface HXBLEUpgradeVC : UIViewController

- (instancetype)initWithBleDevicee:(HXBLEDevice *)bleDevice;

@end

NS_ASSUME_NONNULL_END
