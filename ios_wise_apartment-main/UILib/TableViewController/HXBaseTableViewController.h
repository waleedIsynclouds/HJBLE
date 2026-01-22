//
//  HXBaseTableViewController.h
//  HXJBLESDKDemo
//
//  Created by JQ on 2019/5/29.
//  Copyright © 2019 JQ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class HXBLEDevice;

@interface HXBaseTableViewController : UITableViewController

@property (nonatomic, strong) HXBLEDevice *bleDevice;

@property (nonatomic, strong) NSMutableArray *dataArray;

- (instancetype)initWithBLEDevice:(HXBLEDevice *)bleDevice;

@end

NS_ASSUME_NONNULL_END
