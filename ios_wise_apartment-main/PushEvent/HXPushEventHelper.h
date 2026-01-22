//
//  HXPushEventHelper.h
//  HXJBLESDKDemo
//
//  Created by JQ on 2019/5/30.
//  Copyright © 2019 JQ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HXRecordCellModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 处理蓝牙锁事件上报，一般情况下客户端将蓝牙锁的件上报数据转发给服务器保存
 ⚠️该类只保存应用程序本次运行期间收到的蓝牙锁事件上报
 */
@interface HXPushEventHelper : NSObject

+ (instancetype)sharedPushEventHelper;

- (NSArray<HXRecordCellModel *> *)loadDataWithLockMac:(NSString *)lockMac;

@end

NS_ASSUME_NONNULL_END
