//
//  HXLockDetailsVC.m
//  HXJBLESDKDemo
//
//  Created by JQ on 2019/5/28.
//  Copyright © 2019 JQ. All rights reserved.
//

#import "HXLockDetailsVC.h"
#import "HXKeyListVC.h"
#import "HXOperationRecordListVC.h"
#import "HXSystemParametersVC.h"
#import "HXPushEventVC.h"
#import "HXBLEUpgradeVC.h"

#import <HXJBLESDK/HXBluetoothLockHelper.h>
#import <HXJBLESDK/HXBluetoothNBInfoHelper.h>
#import <HXJBLESDK/HXBluetoothCat1InfoHelper.h>
#import <HXJBLESDK/JQBLEDefines.h>
#import <HXJBLESDK/HXLockNetSystemFunctionModel.h>

#import "HXCenterTitleCell.h"
#import "HXTitleCellModel.h"
#import "HXSectionModel.h"

#import "HXCoreDataStackHelper.h"
#import "HXAuthHelper.h"
#import "HXLockRFModuleTypeFunc.h"

typedef NS_ENUM(NSInteger, kLockDetailsCellType) {
    kLockDetailsCellType_unlock = 1,
    kLockDetailsCellType_keyList,
    kLockDetailsCellType_setSystemParameters,
    kLockDetailsCellType_synchronizeTime,
    kLockDetailsCellType_OperationRecordList,
    kLockDetailsCellType_PushEvent,
    kLockDetailsCellType_nbInfo,
    kLockDetailsCellType_cat1Info,
    kLockDetailsCellType_setLockKeyExpirationAlarmTime,
    kLockDetailsCellType_upgrade,
    kLockDetailsCellType_delete,
};

@interface HXLockDetailsVC ()

@property (nonatomic, strong) HXBluetoothNBInfoHelper *nbInfoHelper;
@property (nonatomic, strong) HXBluetoothCat1InfoHelper *cat1InfoHelper;

@property (nonatomic, strong) HXAuthHelper *authHelper;

@end

@implementation HXLockDetailsVC

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithBLEDevice:(HXBLEDevice *)bleDevice
{
    self = [super initWithBLEDevice:bleDevice];
    if (self) {
        [self prepare];
    }
    return self;
}

#pragma mark -特别注意⚠️调用HXBluetoothLockHelper中其它方法之前，要先设置一次蓝牙设备的基础配置信息，否则控制会返回228错误码。如果后续参数有更新需要再调用该接口。
#pragma mark *****************************************************
- (void)prepare
{
    [HXBluetoothLockHelper setDeviceAESKey:self.bleDevice.aesKey authCode:self.bleDevice.adminAuthCode keyGroupId:900 bleProtocolVersion:self.bleDevice.bleProtocolVersion lockMac:self.bleDevice.lockMac];
    
    /**
     当App无法获取到门锁的aesKey、authCode时，调用该方法设置一个蓝牙设备的基础配置信息，并创建一个对象实现HXBLESecureAuthProtocol协议，从自己的服务器获取对应的数据
    if (!_authHelper) {
        _authHelper = [[HXAuthHelper alloc] init];
    }
    [HXBluetoothLockHelper setKeyGroupId:900 bleProtocolVersion:self.bleDevice.bleProtocolVersion lockMac:self.bleDevice.lockMac secureAuthObj:_authHelper];
     */
}

- (void)loadData
{
    HXSectionModel *section1 = [self addSection];
    [self section:section1 addCellWithType:kLockDetailsCellType_unlock];

    HXSectionModel *section2 = [self addSection];
    [self section:section2 addCellWithType:kLockDetailsCellType_keyList];
    
    HXSectionModel *section3 = [self addSection];
    [self section:section3 addCellWithType:kLockDetailsCellType_OperationRecordList];
    [self section:section3 addCellWithType:kLockDetailsCellType_PushEvent];

    HXSectionModel *section4 = [self addSection];
    [self section:section4 addCellWithType:kLockDetailsCellType_setSystemParameters];
    [self section:section4 addCellWithType:kLockDetailsCellType_synchronizeTime];

    kHXRFModuleType rfType = self.bleDevice.rfModuleType;
    if ([HXLockRFModuleTypeFunc isHXJNBIoTRFType:rfType]) {
        HXSectionModel *section = [self addSection];
        [self section:section addCellWithType:kLockDetailsCellType_nbInfo];
        
    }else if ([HXLockRFModuleTypeFunc isCat1RFType:rfType]) {
        HXSectionModel *section = [self addSection];
        [self section:section addCellWithType:kLockDetailsCellType_cat1Info];
    }
    
    HXLockNetSystemFunctionModel *lockNetSystemFunctionObj = [[HXLockNetSystemFunctionModel alloc] initWithLockNetSystemFunction:self.bleDevice.lockNetSystemFunction];
    if (lockNetSystemFunctionObj.supportExpirationAlarmTime == 1) {
        HXSectionModel *lockKeyExpirationAlarmSection = [self addSection];
        [self section:lockKeyExpirationAlarmSection addCellWithType:kLockDetailsCellType_setLockKeyExpirationAlarmTime];
    }
    
    HXSectionModel *upgradeSection = [self addSection];
    [self section:upgradeSection addCellWithType:kLockDetailsCellType_upgrade];
    
    HXSectionModel *section6 = [self addSection];
    [self section:section6 addCellWithType:kLockDetailsCellType_delete];
    
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = self.bleDevice.lockMac;
    [self setConnectStatus];
    [self loadData];
    [self autoConnectBLELock];
    [self addNotification];
}

- (void)setConnectStatus
{
    if ([HXBluetoothLockHelper getConnectStatusWithLockMac:self.bleDevice.lockMac]) {
        setNaviBarRightTitleButton(NSLocalizedString(@"Connected", @"已连接"), self, @selector(disconnectBLELock));
    }else {
        setNaviBarRightTitleColorButton(NSLocalizedString(@"Disconnect", @"未连接"), self, nil, [UIColor grayColor]);
    }
}

- (void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectNotification:) name:KSHNotification_BLEConnect object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnectNotification:) name:KSHNotification_BLEDisconnect object:nil];
}

- (void)autoConnectBLELock
{
    NSLog(@"尝试自动连接蓝牙锁，加快后续控制命令的速度");
    [HXBluetoothLockHelper connectPeripheralWithMac:self.bleDevice.lockMac completionBlock:nil];
}

- (void)disconnectBLELock
{
    [SHCommonFunc showAlertViewWithTitle:NSLocalizedString(@"Disconnect the phone from the Bluetooth lock directly?", @"直接断开手机与蓝牙锁的连接？") message:nil btn1Title:NSLocalizedString(@"Cancel", @"取消") btn2Title:NSLocalizedString(@"Disconnect_", @"断开") btn1Block:nil btn2Block:^{
        [HXBluetoothLockHelper disconnectPeripheralWithMac:self.bleDevice.lockMac];
    } animated:YES ctl:self];
}

- (void)connectNotification:(NSNotification *)notification
{
    NSString *mac = notification.object;
    if ([mac isEqualToString:self.bleDevice.lockMac]) {
        setNaviBarRightTitleButton(NSLocalizedString(@"Connected", @"已连接"), self, @selector(disconnectBLELock));
    }
}

- (void)disconnectNotification:(NSNotification *)notification
{
    NSString *mac = notification.object;
    if ([mac isEqualToString:self.bleDevice.lockMac]) {
        setNaviBarRightTitleColorButton(NSLocalizedString(@"Disconnect", @"未连接"), self, nil, [UIColor grayColor]);
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    HXSectionModel *sectionModel = [self.dataArray objectAtIndex:section];
    return sectionModel.cellModelArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HXSectionModel *sectionModel = [self.dataArray objectAtIndex:indexPath.section];
    HXTitleCellModel *cellModel = [sectionModel cellModelAtIndex:indexPath.row];
    kLockDetailsCellType type = cellModel.type;
    if (type == kLockDetailsCellType_unlock ||
        type == kLockDetailsCellType_delete) {
        HXCenterTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:[HXCenterTitleCell cellReuseIdentifier]];
        if (!cell) {
            cell = [[HXCenterTitleCell alloc] init];
        }
        if (type == kLockDetailsCellType_unlock) {
            cell.textLabel.textColor = [UIColor blackColor];
        }else {
            cell.textLabel.textColor = [UIColor redColor];
        }
        cell.textLabel.text = cellModel.title;
        return cell;
    }else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"comCellIdentifier"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"comCellIdentifier"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        cell.textLabel.text = cellModel.title;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    HXSectionModel *sectionModel = [self.dataArray objectAtIndex:indexPath.section];
    HXTitleCellModel *cellModel = [sectionModel cellModelAtIndex:indexPath.row];
    kLockDetailsCellType type = cellModel.type;
    if (type == kLockDetailsCellType_unlock) {
        [self unlock];
    }else if (type == kLockDetailsCellType_delete) {
        [self delete];
    }else if (type == kLockDetailsCellType_synchronizeTime) {
        [self synchronizeTime];
    }else if (type == kLockDetailsCellType_keyList) {
        HXKeyListVC *vc = [[HXKeyListVC alloc] initWithBLEDevice:self.bleDevice];
        pushViewCtl(self, vc);
    }else if (type == kLockDetailsCellType_OperationRecordList) {
        HXOperationRecordListVC *vc = [[HXOperationRecordListVC alloc] initWithBLEDevice:self.bleDevice];
        pushViewCtl(self, vc);
    }else if (type == kLockDetailsCellType_setSystemParameters) {
        HXSystemParametersVC *vc = [[HXSystemParametersVC alloc] initWithBLEDevice:self.bleDevice];
        pushViewCtl(self, vc);
    }else if (type == kLockDetailsCellType_PushEvent) {
        HXPushEventVC *vc = [[HXPushEventVC alloc] initWithBLEDevice:self.bleDevice];
        pushViewCtl(self, vc);
    }else if (type == kLockDetailsCellType_nbInfo) {
        [self getNBIoTModuleInfo];
    }else if (type == kLockDetailsCellType_cat1Info) {
        [self getCat1ModuleInfo];
    }
    else if (type == kLockDetailsCellType_upgrade) {
        [self pushUpgradeVC];
    }else if (type == kLockDetailsCellType_setLockKeyExpirationAlarmTime) {
        [self setKeyExpirationAlarmTime];
    }
}

/// 设置蓝牙锁使用有效期
- (void)test_setLockExpirationTime
{
    [HXBluetoothLockHelper setLockExpirationTimeWithLockMac:self.bleDevice.lockMac remainningTime:3600*24+15 promptDays:1 completionBlock:^(KSHStatusCode statusCode, NSString *reason) {
        
        NSString *tips = bleCommonTips(reason, statusCode);
        NSLog(@"%@",tips);
    }];
}


/// 获取蓝牙锁使用有效期
- (void)test_getLockExpirationTime
{
    [HXBluetoothLockHelper getLockExpirationTimeWithLockMac:self.bleDevice.lockMac completionBlock:^(KSHStatusCode statusCode, NSString *reason, long remainningTime, int promptDays) {
        NSString *tips = bleCommonTips(reason, statusCode);
        NSLog(@"%@",tips);
    }];
}


/// 设置蓝牙锁钥匙到期提醒时间
- (void)setKeyExpirationAlarmTime {
    SHBLEHotelLockSystemParam *param = [[SHBLEHotelLockSystemParam alloc] init];
    param.lockMac = self.bleDevice.lockMac;
    param.expirationAlarmTime = 30;// 钥匙在30天内过期，开锁时会播报语音提醒
    showAlertView(NSLocalizedString(@"Setting up, please wait...", @"设置中，请稍后..."), self);
    __weak typeof(self)wself = self;
    [HXBluetoothLockHelper setHotelLockSystemParam:param completionBlock:^(KSHStatusCode statusCode, NSString *reason) {
        if (statusCode == KSHStatusCode_Success) {
            showDurationAlertView(NSLocalizedString(@"Localizable_Successfully", @"成功"), wself, 1);
            NSLog(@"成功");
        }else {
            NSLog(@"失败");
            NSString *tips = bleCommonTips(reason, statusCode);
            showDurationAlertView(tips, wself, 1.5);
        }
    }];
}

/// 获取蓝牙锁钥匙到期提醒时间
- (void)getKeyExpirationAlarmTime {
    showAlertView(NSLocalizedString(@"Setting up, please wait...", @"获取中，请稍后..."), self);
    __weak typeof(self)wself = self;
    [HXBluetoothLockHelper getHotelLockSystemParamWithLockMac:self.bleDevice.lockMac complectionBlock:^(KSHStatusCode statusCode, NSString *reason, SHBLEHotelLockSystemParam *param) {
    
        if (statusCode == KSHStatusCode_Success) {
            NSLog(@"param = %@", param);
            showDurationAlertView(NSLocalizedString(@"Localizable_Successfully", @"成功"), wself, 1);
            NSLog(@"成功");
        }else {
            NSLog(@"失败");
            NSString *tips = bleCommonTips(reason, statusCode);
            showDurationAlertView(tips, wself, 1.5);
        }
    }];
}

- (void)unlock
{
    showAlertView(NSLocalizedString(@"Unlocking, please wait...", @"开锁中，请稍后..."), self);
    __weak typeof(self)wself = self;
    [HXBluetoothLockHelper unlockWithMac:self.bleDevice.lockMac synchronizeTime:YES completionBlock:^(KSHStatusCode statusCode, NSString *reason, NSString *mac, int power, int unlockingDuration) {
        if (statusCode == KSHStatusCode_Success) {
            showDurationAlertView(NSLocalizedString(@"Successfully unlocked", @"开锁成功"), wself, 1);
            NSLog(@"开锁成功");
        }else {
            NSLog(@"开锁失败");
            NSString *tips = bleCommonTips(reason, statusCode);
            showDurationAlertView(tips, wself, 1.5);
        }
    }];
}

- (void)delete
{
    __weak typeof(self)wself = self;
    [SHCommonFunc showAlertViewWithTitle:NSLocalizedString(@"Are you sure to delete the Bluetooth lock?", @"确认删除该蓝牙锁？") message:nil btn1Title:NSLocalizedString(@"Cancel", @"取消") btn2Title:NSLocalizedString(@"Delete", @"删除") btn1Block:nil btn2Block:^{
        showAlertView(NSLocalizedString(@"Deleting, please wait...", @"删除中，请稍后..."), wself);
        [HXBluetoothLockHelper deleteDeviceWithMac:wself.bleDevice.lockMac completionBlock:^(KSHStatusCode statusCode, NSString *reason) {
            if (statusCode == KSHStatusCode_Success) {
                [HXCoreDataStackHelper deleteDeviceWithLockMac:wself.bleDevice.lockMac];
                showCompletionBlockAlertView(NSLocalizedString(@"successfully deleted", @"删除成功"), wself, 1, ^{
                    [wself.navigationController popViewControllerAnimated:YES];
                });
            }else {
                NSString *tips = [NSString stringWithFormat:@"%@[%ld]",reason, (long)statusCode];
                showDurationAlertView(tips, wself, 2);
            }
        }];
        
    } animated:YES ctl:self];
}

- (void)synchronizeTime
{
    __weak typeof(self)wself = self;
    [SHCommonFunc showAlertViewWithTitle:NSLocalizedString(@"Will the calibration time of the Bluetooth lock be the same as the mobile phone?", @"将校准蓝牙锁时间和手机一致？") message:nil btn1Title:NSLocalizedString(@"Cancel", @"取消") btn2Title:NSLocalizedString(@"Confirm", @"确定") btn1Block:nil btn2Block:^{
        showAlertView(NSLocalizedString(@"Calibration time, please wait...", @"校准时间中，请稍后..."), wself);
        [HXBluetoothLockHelper synchronizeTimeWithMac:wself.bleDevice.lockMac completionBlock:^(KSHStatusCode statusCode, NSString *reason) {
            if (statusCode == KSHStatusCode_Success) {
                showDurationAlertView(NSLocalizedString(@"Successfully", @"成功"), wself, 1);
            }else {
                NSString *tips = bleCommonTips(reason, statusCode);
                showDurationAlertView(tips, wself, 2);
            }
        }];
    } animated:YES ctl:self];
}

- (void)getNBIoTModuleInfo
{
    if (!_nbInfoHelper) {
        _nbInfoHelper = [[HXBluetoothNBInfoHelper alloc] init];
    }
    __weak typeof(self)wSelf = self;
    showAlertView(NSLocalizedString(@"While obtaining information, please wait patiently...", @"获取信息中，请耐心等待..."), self);
    [_nbInfoHelper getNBRegistInfoWithLockMac:self.bleDevice.lockMac completionBlock:^(KSHStatusCode statusCode, NSString * _Nonnull reason, NSString * _Nonnull cardID, NSString * _Nonnull IMEI, NSString * _Nonnull csq) {
        NSString *title = statusCode==KSHStatusCode_Success?NSLocalizedString(@"Succeeded in obtaining NBIoT module information", @"获取NBIoT模组信息成功"):NSLocalizedString(@"Failed to obtain NBIoT module information", @"获取NBIoT模组信息失败");
        NSString *message = nil;
        if (statusCode == KSHStatusCode_Success) {
            message = [NSString stringWithFormat:NSLocalizedString(@"IoT card number: %@\nIMEI number: %@\nSignal quality: %@", @"物联网卡号：%@\nIMEI号：%@\n信号质量：%@"),cardID,IMEI,csq];
        }else {
            message = bleCommonTips(reason, (int)statusCode);
        }
        [SHCommonFunc showAlertViewWithTitle:title message:message btnTitle:NSLocalizedString(@"Confirm", @"确认") btnBlock:nil ctl:wSelf];
    }];
}

- (void)getCat1ModuleInfo
{
    if (!_cat1InfoHelper) {
        _cat1InfoHelper = [[HXBluetoothCat1InfoHelper alloc] init];
    }
    __weak typeof(self)wSelf = self;
    showAlertView(NSLocalizedString(@"While obtaining information, please wait patiently...", @"获取信息中，请耐心等待..."), self);
    [_cat1InfoHelper getCat1RegistInfoWithLockMac:self.bleDevice.lockMac completionBlock:^(KSHStatusCode statusCode, NSString * _Nonnull reason, NSString * _Nonnull ICCID, NSString * _Nonnull IMEI, NSString * _Nonnull IMSI, NSString * _Nonnull RSSI, NSString * _Nonnull RSRP, NSString * _Nonnull SINR) {
        
        NSString *title = statusCode==KSHStatusCode_Success?NSLocalizedString(@"Succeeded in obtaining Cat1 module information", @"获取Cat.1模组信息成功"):NSLocalizedString(@"Failed to obtain Cat1 module information", @"获取Cat.1模组信息失败");
        NSString *message = nil;
        if (statusCode == KSHStatusCode_Success) {
            message = [NSString stringWithFormat:@"ICCID: %@\nIMEI: %@\nIMSI: %@\nRSSI: %@\nRSRP: %@\nSINR: %@\n",ICCID, IMEI, IMSI, RSSI, RSRP, SINR];
            /// ICCID: 集成电路卡识别码即SIM卡卡号
            /// IMEI：IMEI号；
            /// IMSI: 表示物联网卡号；
            /// RSSI：表示当前信号质量；
            /// RSRP: 信号接收功率;
            /// SINR: 信号与干扰+噪声比
        }else {
            message = bleCommonTips(reason, (int)statusCode);
        }
        [SHCommonFunc showAlertViewWithTitle:title message:message btnTitle:NSLocalizedString(@"Confirm", @"确认") btnBlock:nil ctl:wSelf];
    }];
}

- (void)pushUpgradeVC
{
    NSLog(@"点击固件升级按钮");
    HXBLEUpgradeVC *vc = [[HXBLEUpgradeVC alloc] initWithBleDevicee:self.bleDevice];
    pushViewCtl(self, vc);
}

#pragma mark -TableViewCell数据处理
- (HXSectionModel *)addSection
{
    HXSectionModel *section = [[HXSectionModel alloc] init];
    [self.dataArray addObject:section];
    return section;
}

- (void)section:(HXSectionModel *)section addCellWithType:(kLockDetailsCellType)type
{
    NSString *title = [self titleWithType:type];
    HXTitleCellModel *cellModel = [[HXTitleCellModel alloc] initWithTitle:title type:type];
    [section addCellModel:cellModel];
}

- (NSString *)titleWithType:(kLockDetailsCellType)type
{
    NSString *title;
    if (type == kLockDetailsCellType_unlock) {
        title = NSLocalizedString(@"Unlock", @"开锁");
    }else if (type == kLockDetailsCellType_keyList) {
        title = NSLocalizedString(@"Key", @"钥匙");
    }else if (type == kLockDetailsCellType_OperationRecordList) {
        title = NSLocalizedString(@"Operation record", @"操作记录");
    }else if (type == kLockDetailsCellType_PushEvent) {
        title = NSLocalizedString(@"Event report", @"事件上报");
    }else if (type == kLockDetailsCellType_setSystemParameters) {
        title = NSLocalizedString(@"Lock system settings", @"系统设置");
    }else if (type == kLockDetailsCellType_synchronizeTime) {
        title = NSLocalizedString(@"Calibration time", @"校准时间");
    }else if (type == kLockDetailsCellType_nbInfo) {
        title = NSLocalizedString(@"Get NBIoT module information", @"获取NBIoT模组信息");
    }else if (type == kLockDetailsCellType_cat1Info) {
        title = NSLocalizedString(@"Get Cat1 module information", @"获取Cat.1模组信息");
    }else if (type == kLockDetailsCellType_delete) {
        title = NSLocalizedString(@"Delete door lock", @"删除门锁");
    }else if (type == kLockDetailsCellType_upgrade) {
        title = NSLocalizedString(@"Lock upgrade", @"固件升级");
    }else if (type == kLockDetailsCellType_setLockKeyExpirationAlarmTime) {
        title = NSLocalizedString(@"setLockKeyExpirationAlarmTime", @"设置用户钥匙到期提醒时间");
    }
    else {
        title = @"";
    }
    return title;
}

@end
