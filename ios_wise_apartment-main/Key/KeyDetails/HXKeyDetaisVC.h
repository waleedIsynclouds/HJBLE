//
//  HXKeyDetaisVC.h
//  HXJBLESDKDemo
//
//  Created by JQ on 2019/5/29.
//  Copyright © 2019 JQ. All rights reserved.
//

#import "HXBaseTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class HXKeyModel;

@interface HXKeyDetaisVC : HXBaseTableViewController

- (instancetype)initWithBLEDevice:(HXBLEDevice *)bleDevice bleKey:(HXKeyModel *)bleKey;

@end

NS_ASSUME_NONNULL_END
