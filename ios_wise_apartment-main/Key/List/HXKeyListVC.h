//
//  HXKeyListVC.h
//  HXJBLESDKDemo
//
//  Created by JQ on 2019/5/29.
//  Copyright © 2019 JQ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class HXBLEDevice;

@interface HXKeyListVC : UIViewController

- (instancetype)initWithBLEDevice:(HXBLEDevice *)bleDevice;

@end

NS_ASSUME_NONNULL_END
