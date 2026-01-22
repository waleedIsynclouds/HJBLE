//
//  HXAddDeviceVC.m
//  HXJBLESDKDemo
//
//  Created by JQ on 2019/5/27.
//  Copyright © 2019 JQ. All rights reserved.
//

#import "HXAddDeviceVC.h"
#import <HXJBLESDK/HXAddBluetoothLockHelper.h>
#import <HXJBLESDK/HXScanAllDevicesHelper.h>
#import "HXVerticalAlignmentLabel.h"
#import "HXCoreDataStackHelper.h"

typedef NS_ENUM(NSInteger, kCurProgress) {
    kCurProgress_Non = 1,
    kCurProgress_Scan,
    kCurProgress_Add,
    kCurProgress_End
};

@interface HXAddDeviceVC ()<HXScanAllDevicesHelperDelegate>

@property (nonatomic, strong) HXScanAllDevicesHelper *scanHelper;

@property (nonatomic, strong) HXAddBluetoothLockHelper *addHelper;

@property (nonatomic, strong) HXVerticalAlignmentLabel *tipsLabel;

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@property (nonatomic, strong) SHAdvertisementModel *advertisementModel;

@property (nonatomic, assign) kCurProgress curProgress;

@end

@implementation HXAddDeviceVC

- (void)dealloc
{
    NSLog(@"%s", __func__);
    if (_curProgress == kCurProgress_Scan) {
        [_scanHelper stopScan];
    }else if (_curProgress == kCurProgress_Add) {
        [_addHelper cancelAddDevice];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _curProgress = kCurProgress_Non;
    [self setupSubviews];
    [self showGuideAlertView];
    [self addNotification];
}

- (void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bleDidUpdateState:) name:kJQNotification_CBManagerDidUpdateState object:nil];
}

- (void)showGuideAlertView
{
    [SHCommonFunc showAlertViewWithTitle:NSLocalizedString(@"Initialize the Bluetooth lock", @"初始化蓝牙锁")  message:NSLocalizedString(@"Press and hold the setting button until you hear \"di di\" twice and then release, the door lock indicator flashes to start adding", @"长按设置键，直到听到“嘀嘀”两声后松开，门锁指示灯闪烁开始添加") btn1Title:NSLocalizedString(@"Cancel", @"取消") btn2Title:NSLocalizedString(@"Start adding", @"开始添加") btn1Block:^{
        [self.navigationController popViewControllerAnimated:YES];
    } btn2Block:^{
        [self startScan];
    } animated:YES ctl:self];
}

- (void)setupSubviews
{
    self.navigationItem.title = NSLocalizedString(@"Add Bluetooth lock", @"添加蓝牙锁");

    self.view.backgroundColor = [UIColor whiteColor];
    _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _indicatorView.frame = CGRectMake((QScreenWidth-50)/2.0, QNavigationBarHeight+35, 50, 50);
    [self.view addSubview:_indicatorView];
    
    CGFloat labelOriginY = CGRectGetMaxY(_indicatorView.frame)+ 30;
    CGFloat labelHeight = QScreenHeight - labelOriginY;
    _tipsLabel = [[HXVerticalAlignmentLabel alloc] initWithFrame:CGRectMake(15, labelOriginY, QScreenWidth-30, labelHeight)];
    _tipsLabel.numberOfLines = 0;
    _tipsLabel.font = [UIFont systemFontOfSize:17];
    _tipsLabel.textColor = RGB(51, 51, 51);
    _tipsLabel.textAlignment = NSTextAlignmentCenter;
    _tipsLabel.verticalAlignment = KLabelVerticalAlignmentTop;
    [self.view addSubview:_tipsLabel];
}

#pragma mark -扫描蓝牙锁
#pragma mark ***************************************
- (void)startScan
{
    if (!_scanHelper) {
        _scanHelper = [[HXScanAllDevicesHelper alloc] initWithDelegate:self];
    }
    [_scanHelper startScanForDevices];
    [_indicatorView startAnimating];
    _tipsLabel.text = NSLocalizedString(@"Scanning for Bluetooth locks that can be added...", @"正在扫描可添加的蓝牙锁...");
    _curProgress = kCurProgress_Scan;
}

#pragma mark -添加蓝牙锁
#pragma mark *****************************************
- (void)startAddDevice
{
    if (_curProgress != kCurProgress_Add) {
        _curProgress = kCurProgress_Add;
        if (!_addHelper) {
            _addHelper = [[HXAddBluetoothLockHelper alloc] init];
        }
        __weak typeof(self)wself = self;
        [_addHelper startAddDeviceWithAdvertisementModel:_advertisementModel completionBlock:^(KSHStatusCode statusCode, NSString *reason, HXBLEDevice *device, HXBLEDeviceStatus *deviceStatus) {
            
            wself.curProgress = kCurProgress_End;
            NSLog(@"%s \n添加蓝牙锁回调：statusCode = %ld, reason = %@, device = %@\n\n deviceDnaInfoStr = %@,\ndeviceStatusStr = %@\n", __func__, (long)statusCode, reason, device, device.deviceDnaInfoStr, deviceStatus.deviceStatusStr);
            if (statusCode == KSHStatusCode_Success) {
                [wself saveDevice:device deviceStatus:deviceStatus];
                [wself showSuccessfullyUI];
                
            }else {
                
                NSString *tips = bleCommonTips(reason, statusCode);
                wself.tipsLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Failed to add Bluetooth lock\nMac: %@\n%@[%ld]", @"添加蓝牙锁失败\nMac：%@\n%@[%ld]"), wself.advertisementModel.mac, tips, (long)statusCode];
                [wself.indicatorView stopAnimating];
            }
        }];
    }
}

- (void)saveDevice:(HXBLEDevice *)device deviceStatus:(HXBLEDeviceStatus *)deviceStatus
{
    [HXCoreDataStackHelper deleteDeviceWithLockMac:device.lockMac];
    [HXCoreDataStackHelper saveDevice:device];
    [HXCoreDataStackHelper saveDeviceStatus:deviceStatus];
}

- (void)showSuccessfullyUI
{
    self.tipsLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Successfully added Bluetooth lock\nMac: %@", @"添加蓝牙锁成功\nMac：%@"), self.advertisementModel.mac];
    [self.indicatorView stopAnimating];
    setNaviBarRightTitleButton(NSLocalizedString(@"Finish", @"完成"), self, @selector(finish));
    
    CGFloat width = 66;
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((QScreenWidth-width)/2.0, QNavigationBarHeight +66, width, width)];
    imgView.image = [UIImage imageNamed:@"success"];
    [self.view addSubview:imgView];
    
    self.tipsLabel.frame = CGRectMake(self.tipsLabel.frame.origin.x, CGRectGetMaxY(imgView.frame)+30, self.tipsLabel.bounds.size.width, self.tipsLabel.bounds.size.height);
}

#pragma mark -蓝牙开关状态变动通知
#pragma mark ***************************************
- (void)bleDidUpdateState:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.curProgress == kCurProgress_Scan) {
            KJQBluetoothState state = [notification.object intValue];
            if (state == KJQBluetoothStatePoweredOn) {
                if (self.indicatorView && !self.indicatorView.isAnimating) {
                    [self.indicatorView startAnimating];
                    self.tipsLabel.text = NSLocalizedString(@"Scanning for Bluetooth locks that can be added...", @"正在扫描可添加的蓝牙锁...");
                }
            }
        }
    });
}

#pragma mark -HXScanAllDevicesHelperDelegate
#pragma mark ***************************************

- (void)didDiscoverDeviceAdvertisement:(NSArray<SHAdvertisementModel *> *)advertisements
{
    NSLog(@"%s \n发现蓝牙锁成功回调:%@",__func__,advertisements);
    [self filterAdvertisements:advertisements];
    if (_advertisementModel) {
        [self startAddDevice];
    }
}

- (void)didFailToScanDevices:(KSHStatusCode)statusCode reason:(NSString *)reason
{
    NSLog(@"%s \n发现蓝牙锁失败回调:statusCode = %ld, reason = %@", __func__, (long)statusCode, reason);
    self.tipsLabel.text = [NSString stringWithFormat:@"%@[%ld]",reason, (long)statusCode];
    [self.indicatorView stopAnimating];
}

#pragma mark -找到处于发现模式、未被添加，并且信号最好的蓝牙锁
#pragma mark *****************************************
- (void)filterAdvertisements:(NSArray<SHAdvertisementModel *> *)advertisements
{
    if (!_advertisementModel) {
        if (advertisements.count > 0) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"discoverableFlag = YES and RSSI.intValue > -80 and isPairedFlag = NO"];
            NSArray *array = [advertisements filteredArrayUsingPredicate:predicate];
            if (array.count > 0) {
                if (array.count > 1) {
                    NSArray *sortedArray = [array sortedArrayUsingComparator:^NSComparisonResult(SHAdvertisementModel *obj1, SHAdvertisementModel *obj2) {
                        return [obj2.RSSI compare:obj1.RSSI];
                    }];
                    _advertisementModel = [sortedArray firstObject];
                    
                } else if (array.count == 1) {
                    _advertisementModel = [array firstObject];
                }
                _tipsLabel.text = NSLocalizedString(@"Scan to add Bluetooth lock, start adding...", @"扫描到可添加的蓝牙锁，开始添加...");
                [_scanHelper stopScan];
            }
        }
    }
}

- (void)finish
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
