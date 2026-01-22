//
//  HXAddFaceHelper.h
//  HXJBLESDKDemo
//
//  Created by JQ on 2023/4/20.
//  Copyright © 2023 JQ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HXJBLESDK/HXKeyModel.h>
#import <HXJBLESDK/SHBLEKeyValidTimeParam.h>


NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, KSHBLESendBigKeyDataPhase) {
    /**
     正在发送数据包，此阶段可根据根据百分比判断进度
     */
    KSHBLESendBigKeyDataPhase_sending = 0,
    /**
     钥匙包发送成功
     */
    KSHBLESendBigKeyDataPhase_end,
};

typedef void(^BLESendBigKeyDataBlock)(NSInteger statusCode, NSString * _Nullable reason, KSHBLESendBigKeyDataPhase phase, CGFloat progress, HXKeyModel *__nullable keyObj);


@interface HXAddBigDataKeyHelper : NSObject

/// 开始添加人脸钥匙/指纹钥匙到门锁中
/// - Parameters:
///   - faceDataBase64Str: 人脸特征值/指纹特征值（注意：该值需要经过服务器进一步处理后获取，避免图片不满足门锁识别的要求）
///   - lockMac: 门锁Mac
///   - keyGroupId: 要添加给哪个用户，表示这个用户的Id（由自己的服务器分配keyGroupId，确保一把锁中用户的keyGroupId不冲突，取值范围：900~4095）
///   - timeParam: 钥匙有效期
///   - progressBlock: 结果回调
- (void)startWithBigDataBase64Str:(NSString *)bigDataBase64Str
                          lockMac:(NSString *)lockMac
                       keyGroupId:(int)keyGroupId
                          keyType:(KSHKeyType)keyType
                        timeParam:(SHBLEKeyValidTimeParam *)timeParam
                    progressBlock:(BLESendBigKeyDataBlock)progressBlock;



/// 取消
- (void)cancel;

@end

NS_ASSUME_NONNULL_END
