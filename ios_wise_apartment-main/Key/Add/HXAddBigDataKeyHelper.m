//
//  HXAddFaceHelper.m
//  HXJBLESDKDemo
//
//  Created by JQ on 2023/4/20.
//  Copyright © 2023 JQ. All rights reserved.
//

#import "HXAddBigDataKeyHelper.h"
#import <HXJBLESDK/HXBluetoothLockHelper.h>
#import "HXBase64Helper.h"
#import "HXCoreDataStackHelper.h"

@interface HXAddBigDataKeyHelper ()

@property (nonatomic, assign) BOOL isCancel;

@property (nonatomic, strong) NSData *keyData;
@property (nonatomic, copy) NSString *lockMac;
@property (nonatomic, assign) int keyGroupId;
@property (nonatomic, copy) BLESendBigKeyDataBlock progressBlock;
@property (nonatomic, assign) KSHKeyType curKeyType;


@property (nonatomic, assign) KSHBLESendBigKeyDataPhase curPhase;
@property (nonatomic, assign) NSInteger lastStatusCode;

@property (nonatomic, strong) SHBLEAddBigDataKeyParam *param;

/// 每包最大发送的字节数
@property (nonatomic, assign) int maxBlockSize;

/// 添加人脸钥匙成功门锁返回的钥匙Id
@property (nonatomic, assign) int lockKeyId;

@property (nonatomic, strong) HXKeyModel *tempKeyObj;

@property (nonatomic, strong) SHBLEKeyValidTimeParam *timeParam;

@end

@implementation HXAddBigDataKeyHelper

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.maxBlockSize = 200;
    }
    return self;
}

#pragma mark -开始
#pragma mark **************************************
- (void)startWithBigDataBase64Str:(NSString *)bigDataBase64Str
                          lockMac:(NSString *)lockMac
                       keyGroupId:(int)keyGroupId
                          keyType:(KSHKeyType)keyType
                        timeParam:(SHBLEKeyValidTimeParam *)timeParam
                    progressBlock:(BLESendBigKeyDataBlock)progressBlock {

    self.curKeyType = keyType;
    self.progressBlock = progressBlock;
    self.lockMac = lockMac;
    self.keyGroupId = keyGroupId;
    self.timeParam = timeParam;
    self.keyData = [HXBase64Helper dataWithBase64Str:bigDataBase64Str];
    [self start];
}

- (void)start {
    _isCancel = NO;
    self.lockKeyId = 0;

    self.param = [[SHBLEAddBigDataKeyParam alloc] init];
    self.param.totalBytesLength = (int)self.keyData.length;
    self.param.currentIndex = 0;
    int totalNum = (int)(self.keyData.length / self.maxBlockSize) + ((self.keyData.length % self.maxBlockSize) == 0?0:1);
    self.param.totalNum = totalNum;
    self.param.keyGroupId = self.keyGroupId;

    if (self.progressBlock) {
        self.curPhase = KSHBLESendBigKeyDataPhase_sending;
        self.lastStatusCode = KSHStatusCode_Success;
        
        self.progressBlock(KSHStatusCode_Success, NSLocalizedString(@"Localizable_preBleSendKeyData", @"准备蓝牙下发钥匙数据..."), KSHBLESendBigKeyDataPhase_sending, 0, nil);
    }

    [self recursionSendKeyData];
}

- (void)cancel
{
    _isCancel = YES;
    self.progressBlock = nil;
    self.keyData = nil;
    self.timeParam = nil;
    self.lockKeyId = 0;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

#pragma mark -递归发送一个人脸/指纹的数据
- (void)recursionSendKeyData
{
    if (_isCancel) {
        return;
    }
    NSInteger currentBytes = self.param.currentIndex * self.maxBlockSize;
    NSRange range = NSMakeRange(currentBytes, self.maxBlockSize);
    if ((currentBytes + self.maxBlockSize) > self.param.totalBytesLength) {
        range.length = (self.param.totalBytesLength - currentBytes);
        NSLog(@"准备下发第%d个包，最后一个包！！！（共%d个包）", self.param.currentIndex, self.param.totalNum);

    }else {
        NSLog(@"准备下发第%d个包（共%d个包）", self.param.currentIndex, self.param.totalNum);
    }
    NSData *sendData = [self.keyData subdataWithRange:range];
    self.param.data = sendData;
    
    __weak typeof(self)weakSelf = self;
    if (self.curKeyType == KSHKeyType_Face) {
        [HXBluetoothLockHelper addFaceKeyDataParam:self.param timeParam:self.timeParam lockMac:self.lockMac completionBlock:^(KSHStatusCode statusCode, NSString *reason, NSInteger currentIndex, int lockKeyId) {
            [weakSelf onBLEAddFaceKeyDataResponse:statusCode reason:reason currentIndex:currentIndex lockKeyId:lockKeyId];
        }];
        
    }else if (self.curKeyType == KSHKeyType_Fingerprint) {
        [HXBluetoothLockHelper addFingerprintKeyDataParam:self.param timeParam:self.timeParam locMac:self.lockMac completionBlock:^(KSHStatusCode statusCode, NSString *reason, NSInteger currentIndex, int lockKeyId) {
            [weakSelf onBLEAddFaceKeyDataResponse:statusCode reason:reason currentIndex:currentIndex lockKeyId:lockKeyId];
        }];
    }
}

- (void)onBLEAddFaceKeyDataResponse:(KSHStatusCode)statusCode
                             reason:(NSString *)reason
                       currentIndex:(NSInteger)currentIndex lockKeyId:(int)lockKeyId {
    if (statusCode == KSHStatusCode_Success) {

        self.param.currentIndex ++;
        self.curPhase = KSHBLESendBigKeyDataPhase_sending;
        if (self.progressBlock) {
            CGFloat progress = (self.param.currentIndex*1.0)/self.param.totalNum;
            if (self.param.currentIndex == self.param.totalNum) {
                progress = 0.98;//等待钥匙生效成功后，再设置为1
            }
            NSLog(@"**************************************\n当前进度%.0f%%（%d/%d）",
                 progress*100,self.param.currentIndex,self.param.totalNum);
            self.lastStatusCode = KSHStatusCode_Success;
            self.progressBlock(KSHStatusCode_Success, NSLocalizedString(@"Localizable_bleSendKeyData", @"蓝牙下发钥匙数据..."), self.curPhase, progress, nil);
        }
        if (self.param.currentIndex == self.param.totalNum) {
            self.lockKeyId = lockKeyId;
            if (self.progressBlock) {
                self.curPhase = KSHBLESendBigKeyDataPhase_end;
                self.lastStatusCode = KSHStatusCode_Success;
                NSString *tips = NSLocalizedString(@"Localizable_AddSuccessfully", @"添加成功");
                [self setupKeyObj];
                self.progressBlock(self.lastStatusCode, tips, self.curPhase, 1, self.tempKeyObj.copy);
            }
        }else {
            [self recursionSendKeyData];
        }

    }else {
        if (self.progressBlock) {
            self.isCancel = YES;
            self.curPhase = KSHBLESendBigKeyDataPhase_sending;
            CGFloat progress = (self.param.currentIndex*1.0)/self.param.totalNum;
            NSString *tips = NSLocalizedString(@"Localizable_FailedToAddKey", @"添加钥匙失败");
            if (statusCode == KSHStatusCode_Failed && self.curKeyType == KSHKeyType_Face) {
                tips = [NSString stringWithFormat:@"%@: \n%@",tips, NSLocalizedString(@"Localizable_AddFaceTips", @"")];
            }else {
                tips = [NSString stringWithFormat:@"%@: %@",tips, bleCommonTips(reason, statusCode)];
            }
            self.lastStatusCode = statusCode;
            self.progressBlock(statusCode, tips, self.curPhase, progress, nil);
        }
    }
}

- (void)setupKeyObj {
    if (!_tempKeyObj) {
        _tempKeyObj = [[HXKeyModel alloc] init];
    }
    _tempKeyObj.lockMac = self.lockMac;
    _tempKeyObj.keyGroupId = self.keyGroupId;
    _tempKeyObj.lockKeyId = self.lockKeyId;
    _tempKeyObj.keyType = self.curKeyType;
    _tempKeyObj.updateTime = [[NSDate date] timeIntervalSince1970];
    _tempKeyObj.validStartTime = self.timeParam.validStartTime;
    _tempKeyObj.validEndTime = self.timeParam.validEndTime;
    _tempKeyObj.validNumber = self.timeParam.vaildNumber;
    _tempKeyObj.authMode = self.timeParam.authMode;
    _tempKeyObj.weeks = self.timeParam.weeks;
    _tempKeyObj.dayStartTimes = self.timeParam.dayStartTimes;
    _tempKeyObj.dayEndTimes = self.timeParam.dayEndTimes;
    _tempKeyObj.deleteFalg = 1;
}



@end
