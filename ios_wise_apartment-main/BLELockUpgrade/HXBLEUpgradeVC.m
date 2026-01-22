//
//  HXBLEUpgradeVC.m
//  HXJBLESDKDemo
//
//  Created by JQ on 2021/4/21.
//  Copyright © 2021 JQ. All rights reserved.
//

#import "HXBLEUpgradeVC.h"
#import <HXJBLESDK/HXBLEUpgradeHelper.h>
#import <HXJBLESDK/HXBluetoothLockHelper.h>
#import <HXJBLESDK/HXBLEDevice.h>

@interface HXBLEUpgradeVC ()

@property (nonatomic, strong) HXBLEDevice *bleDevice;

@property (nonatomic, strong) UIProgressView *progressView;

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@property (nonatomic, strong) UILabel *tipsLabel;

@property (nonatomic, assign) KSHBLEUpgradePhase phase;

@property (nonatomic, assign) BOOL isUpgrading;

@property (nonatomic, assign) int retryCount;

@end

@implementation HXBLEUpgradeVC

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (self.isUpgrading) {
        NSString *lockMac = self.bleDevice.lockMac;
        [HXBLEUpgradeHelper cancelUpgradeWithMac:lockMac];
        NSLog(@"取消升级");
    }
}

- (instancetype)initWithBleDevicee:(HXBLEDevice *)bleDevice
{
    self = [super init];
    if (self) {
        self.bleDevice = bleDevice;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.retryCount = 0;

    [self setupSubviews];
    [self start];
}

- (void)setupSubviews
{
    self.navigationItem.title = NSLocalizedString(@"Firmware upgrade", @"固件升级");
    self.view.backgroundColor = [UIColor whiteColor];
    
    setNaviBarRightTitleButton(NSLocalizedString(@"Hardware version number", @"硬件版本号"), self, @selector(showHardwareVersionInfo));

    CGSize size = CGSizeMake(30, 30);
    _indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((QScreenWidth-size.width)/2.0, QNavigationBarHeight + 39, size.width, size.height)];
    _indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    _indicatorView.hidesWhenStopped = YES;
    [self.view addSubview:_indicatorView];
    [_indicatorView startAnimating];
    
    _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(_indicatorView.frame) + 80, QScreenWidth-40, 66)];
    [self.view addSubview:_progressView];
    
    _tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(_progressView.frame) + 20, QScreenWidth-30, 80)];
    _tipsLabel.textColor = RGB(51, 51, 51);
    _tipsLabel.textAlignment = NSTextAlignmentCenter;
    _tipsLabel.numberOfLines = 0;
    _tipsLabel.adjustsFontSizeToFitWidth = YES;
    _tipsLabel.font = [UIFont systemFontOfSize:17];
    [self.view addSubview:_tipsLabel];
}

- (void)showHardwareVersionInfo
{
    NSString *tips = [NSString stringWithFormat:NSLocalizedString(@"Note: The hardware version number of the firmware package must be consistent with the lock to avoid abnormalities in the lock board after the upgrade. \n\nThe hardware version number of the current lock:\n%@", @"注意：固件包的硬件版本号要与锁一致，避免升级后锁板异常。\n\n当前锁的硬件版本号：\n%@"),self.bleDevice.hardwareVersion];
    showDurationAlertView(tips, self, 3);
}

- (void)start
{
#warning TODO 注意：这里要替换为指定硬件版本号的蓝牙锁固件路径，一般为App用HTTP将固件从服务器下载到本地，将文件路径传给SDK
    NSString *localFilePath = nil;
    //可以是NSBundle路径，例如
    localFilePath = [[NSBundle mainBundle] pathForResource:@"MTBL_HXJ41_HF_FK_V1A_01000415_HS6621CG_OTA_20210721_1730_signed" ofType:@".zip"];
    //或者沙盒文件路径，例如：
    //localFilePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"xxx.bin"];
    
    NSLog(@"当前锁的硬件版本号：%@，\n固件版本号：%@",self.bleDevice.hardwareVersion, self.bleDevice.firmwareVersion);
    self.isUpgrading = YES;
    __weak typeof(self)weakSelf = self;
    NSString *lockMac = self.bleDevice.lockMac;
    [HXBLEUpgradeHelper startUpgradeWithMac:lockMac localFilePath:localFilePath callback:^(KSHBLEUpgradePhase phase, int upgradeProgress, kBLEChipType chipType, NSError *error, NSString *lockMac) {
        
        if (error) {
            NSLog(@"失败：%@",error);
            BOOL needAutoRetry = NO;

            if (error.code == 12) {//小概率下出现传输失败的情况，可尝试重新固件升级，最多尝试2次，基本可以解决失败的情况
                if (weakSelf.retryCount < 2) {
                    weakSelf.retryCount ++;
                    needAutoRetry = YES;
                }
            }
            
            if (needAutoRetry) {
                [weakSelf performSelector:@selector(start) withObject:nil afterDelay:1.5];
                
            }else {
                weakSelf.isUpgrading = NO;
                [weakSelf.indicatorView stopAnimating];
                weakSelf.tipsLabel.text = [NSString stringWithFormat:NSLocalizedString(@"[%@ phase] %@", @"【%@阶段】%@"),[weakSelf tipsStringWithPhase:phase], error.localizedDescription];
            }
            
        }else {
            if (phase == KSHBLEUpgradePhase_Updating) {
                CGFloat progress = upgradeProgress/100.0;
                weakSelf.progressView.progress = progress;
                NSLog(@"升级进度：%d%%",upgradeProgress);
                weakSelf.tipsLabel.text = [NSString stringWithFormat:@"%@...(%d%%)",[weakSelf tipsStringWithPhase:phase],upgradeProgress];

            }else {
                weakSelf.tipsLabel.text = [NSString stringWithFormat:@"%@...",[weakSelf tipsStringWithPhase:phase]];
                if (phase == KSHBLEUpgradePhase_End) {
                    NSLog(@"升级完成，等待设备重启");
                    weakSelf.tipsLabel.text = [NSString stringWithFormat:@"%@...",[weakSelf tipsStringWithPhase:phase]];
                    weakSelf.isUpgrading = NO;
                    NSTimeInterval afterDelay = 15;
                    if (chipType == kBLEChipType_B) {
                        afterDelay = 3;
                    }
                    [weakSelf performSelector:@selector(getDNAInfo) withObject:nil afterDelay:afterDelay];
                }
            }
        }
    }];
}

#pragma mark -HXJ01锁更新DNA信息
#pragma mark *****************************************
- (void)getDNAInfo
{
    NSString *lockMac = self.bleDevice.lockMac;
    __weak typeof(self)weakSelf = self;
    [HXBluetoothLockHelper getDNAInfoWithLockMac:lockMac completionBlock:^(KSHStatusCode statusCode, NSString *reason, HXBLEDeviceBase *deviceBase) {
        if (statusCode == KSHStatusCode_Success) {
            weakSelf.tipsLabel.text = NSLocalizedString(@"update completed", @"升级完成");
            [weakSelf.indicatorView stopAnimating];
            
            NSString *message = [NSString stringWithFormat:NSLocalizedString(@"The firmware version number of the door lock after the upgrade:\n%@\n\nHardware version number:\n%@", @"升级后门锁的固件版本号：\n%@\n\n硬件版本号：\n%@"),deviceBase.firmwareVersion, deviceBase.hardwareVersion];
            [SHCommonFunc showAlertViewWithTitle:NSLocalizedString(@"update completed", @"升级完成") message:message btnTitle:NSLocalizedString(@"Finish", @"完成") btnBlock:^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            } ctl:weakSelf];
        }else {
            
            NSString *tips = bleCommonTips(reason, statusCode);

            [SHCommonFunc showAlertViewWithTitle:NSLocalizedString(@"Failed to obtain door lock information", @"获取门锁信息失败") message:tips btn1Title:NSLocalizedString(@"Exit", @"退出") btn2Title:NSLocalizedString(@"Retry", @"重试") btn1Block:^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            } btn2Block:^{
                [weakSelf getDNAInfo];
            } animated:YES ctl:weakSelf];
        }
    }];
}


- (NSString *)tipsStringWithPhase:(KSHBLEUpgradePhase)phase
{
    NSString *tips;
    switch (phase) {
        
        case KSHBLEUpgradePhase_Prepare:
            tips = NSLocalizedString(@"Ready to upgrade", @"准备升级");
            break;
            
        case KSHBLEUpgradePhase_Updating:
            tips = NSLocalizedString(@"upgrading", @"正在升级");
            break;
            
        case KSHBLEUpgradePhase_End:
            tips = NSLocalizedString(@"Wait for the device to restart, please wait", @"等待设备重启，请稍后");
            break;
            
        default:
            tips = @"";
            break;
    }
    return tips;
}




@end
