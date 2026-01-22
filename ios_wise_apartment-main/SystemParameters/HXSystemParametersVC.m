//
//  HXSystemParametersVC.m
//  HXJBLESDKDemo
//
//  Created by JQ on 2019/5/30.
//  Copyright © 2019 JQ. All rights reserved.
//

#import "HXSystemParametersVC.h"
#import "HXCoreDataStackHelper.h"
#import "HXTitleCellModel.h"
#import "HXSectionModel.h"
#import "HXResolutionFunc.h"
#import <HXJBLESDK/HXBluetoothLockHelper.h>

typedef NS_ENUM(NSInteger, HXSystemParametersVCCellType) {
    /** 组合开锁 */
    HXSystemParametersVCCellType_openMode,
    /** 常开模式 */
    HXSystemParametersVCCellType_normallyOpenMode,
    /** 开门语音 */
    HXSystemParametersVCCellType_volumeEnable,
    /** 系统音量 */
    HXSystemParametersVCCellType_systemVolume,
    /** 防撬报警 */
    HXSystemParametersVCCellType_shackleAlarmEnable,
    /** 锁芯报警 */
    HXSystemParametersVCCellType_lockCylinderAlarmEnable,
    /** 反锁功能 */
    HXSystemParametersVCCellType_antiLockEnable,
    /** 锁头盖报警 */
    HXSystemParametersVCCellType_lockCoverAlarmEnable,
    /** 系统音量 */
    HXSystemParametersVCCellType_systemLanguage,
};

@interface HXSystemParametersVC ()

@property (nonatomic, strong) HXBLEDeviceStatus *bleDeviceStatus;

@end

@implementation HXSystemParametersVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"Lock system settings",@"系统设置");
    setNaviBarRightSystemButton(UIBarButtonSystemItemRefresh, self, @selector(refresh));
    [self loadData];
}

- (void)loadData
{
    [self.dataArray removeAllObjects];
    if (!_bleDeviceStatus) {
        _bleDeviceStatus = [HXCoreDataStackHelper deviceStatusWithLockMac:self.bleDevice.lockMac];
    }
    
    [self addSectionWithTypes:@[@(HXSystemParametersVCCellType_openMode), @(HXSystemParametersVCCellType_normallyOpenMode), @(HXSystemParametersVCCellType_antiLockEnable)]];
    
    [self addSectionWithTypes:@[@(HXSystemParametersVCCellType_volumeEnable), @(HXSystemParametersVCCellType_systemVolume)]];

    [self addSectionWithTypes:@[@(HXSystemParametersVCCellType_shackleAlarmEnable), @(HXSystemParametersVCCellType_lockCylinderAlarmEnable), @(HXSystemParametersVCCellType_lockCoverAlarmEnable)]];

    [self addSectionWithTypes:@[@(HXSystemParametersVCCellType_systemLanguage)]];

    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    HXSectionModel *sectionModel = [self.dataArray objectAtIndex:section];
    return sectionModel.cellModelArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HXSectionModel *sectionModel = [self.dataArray objectAtIndex:indexPath.section];
    HXTitleCellModel *cellModel = [sectionModel cellModelAtIndex:indexPath.row];
    
    if (cellModel.type == HXSystemParametersVCCellType_systemVolume ||
        cellModel.type == HXSystemParametersVCCellType_systemLanguage) {
        
        static NSString *reuseIdentifier = @"sysParamsReuseIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
        }
        cell.textLabel.text = cellModel.title;
        cell.detailTextLabel.text = cellModel.details;
        return cell;

    }else {
        
        static NSString *switchReuseIdentifier = @"switchReuseIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:switchReuseIdentifier];
        UISwitch *tailSwitch = (UISwitch *)cell.accessoryView;
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:switchReuseIdentifier];
            tailSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
            [tailSwitch addTarget:self action:@selector(tailSwitchChange:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = tailSwitch;
        }
        cell.textLabel.text = cellModel.title;
        tailSwitch.tag = cellModel.type;
        [tailSwitch setOn:(cellModel.value==1?YES:NO)];
        return cell;
    }
}

- (void)tailSwitchChange:(UISwitch *)sender
{
    BOOL isOn = sender.isOn;
    HXSystemParametersVCCellType type = sender.tag;
    int value = isOn?1:2;
    [self setSystemParameterWithType:type value:value sender:sender];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    HXSectionModel *sectionModel = [self.dataArray objectAtIndex:indexPath.section];
    HXTitleCellModel *cellModel = [sectionModel cellModelAtIndex:indexPath.row];
    [self setSystemParameterWithType:cellModel.type value:1 sender:nil];
}

- (void)setSystemParameterWithType:(HXSystemParametersVCCellType)type value:(int)value sender:(UISwitch *)sender
{
    HXSetSystemParameters *params = [self setupParamsWithType:type value:value];
    showAlertView(NSLocalizedString(@"Setting up, please wait...",@"设置中，请稍后..."), self);
    __weak typeof(self)wself = self;
    [HXBluetoothLockHelper setSystemParameters:params completionBlock:^(KSHStatusCode statusCode, NSString *reason) {
        if (statusCode == KSHStatusCode_Success) {
            [wself updateBLEDeviceStatusWithType:type value:value];
            showDurationAlertView(NSLocalizedString(@"Successfully",@"成功"), wself, 1.5);
        }else {
            if (sender) {
                [sender setOn:!sender.isOn animated:YES];
            }
            NSString *tips = bleCommonTips(reason, statusCode);
            showDurationAlertView(tips, wself, 2);
        }
    }];
}

- (void)refresh
{
    [SHCommonFunc showAlertViewWithTitle:NSLocalizedString(@"Sync the latest status to the Bluetooth lock", @"向蓝牙锁同步最新状态") message:nil btn1Title:NSLocalizedString(@"Cancel",@"取消") btn2Title:NSLocalizedString(@"Confirm",@"确定") btn1Block:nil btn2Block:^{
        __weak typeof(self)wself = self;
        showAlertView(NSLocalizedString(@"Syncing, please wait...",@"同步中，请稍后..."), self);
        [HXBluetoothLockHelper getDeviceStatusWithMac:self.bleDevice.lockMac completionBlock:^(KSHStatusCode statusCode, NSString *reason, HXBLEDeviceStatus *deviceStatus) {
            
            if (statusCode == KSHStatusCode_Success) {
                NSLog(@"%s\n deviceStatusStr = %@", __FUNCTION__, deviceStatus.deviceStatusStr);
                showDurationAlertView(NSLocalizedString(@"Successfully",@"成功"), wself, 1.5);
                if (deviceStatus) {
                    [HXCoreDataStackHelper saveDeviceStatus:deviceStatus];
                    wself.bleDeviceStatus = deviceStatus;
                    [wself loadData];
                }
            }else {
                NSString *tips = bleCommonTips(reason, statusCode);
                showDurationAlertView(tips, wself, 2);
            }
        }];
    } animated:YES ctl:self];
}


- (HXSetSystemParameters *)setupParamsWithType:(HXSystemParametersVCCellType)type value:(int)value
{
    HXSetSystemParameters *params = [[HXSetSystemParameters alloc] init];
    params.lockMac = self.bleDevice.lockMac;
    if (type == HXSystemParametersVCCellType_openMode) {
        params.openMode = value;
    }if (type == HXSystemParametersVCCellType_normallyOpenMode) {
        params.normallyOpenMode = value;
    }if (type == HXSystemParametersVCCellType_volumeEnable) {
        params.volumeEnable = value;
    }if (type == HXSystemParametersVCCellType_systemVolume) {
        params.systemVolume = value;
    }if (type == HXSystemParametersVCCellType_shackleAlarmEnable) {
        params.shackleAlarmEnable = value;
    }if (type == HXSystemParametersVCCellType_lockCylinderAlarmEnable) {
        params.lockCylinderAlarmEnable = value;
    }if (type == HXSystemParametersVCCellType_antiLockEnable) {
        params.antiLockEnable = value;
    }if (type == HXSystemParametersVCCellType_lockCoverAlarmEnable) {
        params.lockCoverAlarmEnable = value;
    }if (type == HXSystemParametersVCCellType_systemLanguage) {
        params.systemLanguage = value;
    }
    return params;
}

- (void)updateBLEDeviceStatusWithType:(HXSystemParametersVCCellType)type value:(int)value
{
    if (type == HXSystemParametersVCCellType_openMode) {
        self.bleDeviceStatus.openMode = value;
    }if (type == HXSystemParametersVCCellType_normallyOpenMode) {
        self.bleDeviceStatus.normallyOpenMode = value;
    }if (type == HXSystemParametersVCCellType_volumeEnable) {
        self.bleDeviceStatus.volumeEnable = value;
    }if (type == HXSystemParametersVCCellType_systemVolume) {
        self.bleDeviceStatus.systemVolume = value;
    }if (type == HXSystemParametersVCCellType_shackleAlarmEnable) {
        self.bleDeviceStatus.shackleAlarmEnable = value;
    }if (type == HXSystemParametersVCCellType_lockCylinderAlarmEnable) {
        self.bleDeviceStatus.lockCylinderAlarmEnable = value;
    }if (type == HXSystemParametersVCCellType_antiLockEnable) {
        self.bleDeviceStatus.antiLockEnable = value;
    }if (type == HXSystemParametersVCCellType_lockCoverAlarmEnable) {
        self.bleDeviceStatus.lockCoverAlarmEnable = value;
    }if (type == HXSystemParametersVCCellType_systemLanguage) {
        self.bleDeviceStatus.systemLanguage = value;
    }
    [HXCoreDataStackHelper saveDeviceStatus:self.bleDeviceStatus];
}

- (HXSectionModel *)addSection
{
    HXSectionModel *section = [[HXSectionModel alloc] init];
    [self.dataArray addObject:section];
    return section;
}

- (void)addSectionWithTypes:(NSArray<NSNumber *> *)types
{
    HXSectionModel *sectionModel;
    for (NSNumber *typeNum in types) {
        HXSystemParametersVCCellType type = typeNum.integerValue;
        HXTitleCellModel *cellModel = [self cellModelWithType:type];
        if (cellModel) {
            if (!sectionModel) {
                sectionModel = [self addSection];
            }
            [sectionModel addCellModel:cellModel];
        }
    }
}

- (HXTitleCellModel *)cellModelWithType:(HXSystemParametersVCCellType)type
{
    int value = [HXSystemParametersVC valueWithType:type deviceStatus:self.bleDeviceStatus];
    if (value == 0) {//0表示没有该功能
        return nil;
    }else {
        NSString *title = [HXSystemParametersVC titleWithType:type];
        HXTitleCellModel *cellModel = [[HXTitleCellModel alloc] initWithTitle:title type:type];
        cellModel.value = value;
        if (type == HXSystemParametersVCCellType_systemVolume) {
            cellModel.details = @(value).stringValue;
        }else if (type == HXSystemParametersVCCellType_systemLanguage) {
            cellModel.details = [HXResolutionFunc systemLanguageString:value];
        }
        return cellModel;
    }
}

+ (NSString *)titleWithType:(HXSystemParametersVCCellType)type
{
    NSString *title = @"";
    if (type == HXSystemParametersVCCellType_openMode) {
        title = NSLocalizedString(@"Combination unlock",@"组合开锁");
    }if (type == HXSystemParametersVCCellType_normallyOpenMode) {
        title = NSLocalizedString(@"Normally open mode",@"常开模式");
    }if (type == HXSystemParametersVCCellType_volumeEnable) {
        title = NSLocalizedString(@"Door opening voice",@"开门语音");
    }if (type == HXSystemParametersVCCellType_systemVolume) {
        title = NSLocalizedString(@"System volume",@"系统音量");
    }if (type == HXSystemParametersVCCellType_shackleAlarmEnable) {
        title = NSLocalizedString(@"Anti-pry alarm",@"防撬报警");
    }if (type == HXSystemParametersVCCellType_lockCylinderAlarmEnable) {
        title = NSLocalizedString(@"Lock core alarm",@"锁芯报警");
    }if (type == HXSystemParametersVCCellType_antiLockEnable) {
        title = NSLocalizedString(@"Anti-lock function",@"反锁功能");
    }if (type == HXSystemParametersVCCellType_lockCoverAlarmEnable) {
        title = NSLocalizedString(@"Lock cover alarm",@"锁头盖报警");
    }if (type == HXSystemParametersVCCellType_systemLanguage) {
        title = NSLocalizedString(@"System language",@"系统语言");
    }
    return title;
}

+ (int)valueWithType:(HXSystemParametersVCCellType)type deviceStatus:(HXBLEDeviceStatus *)bleDeviceStatus
{
    int value = 0;
    if (type == HXSystemParametersVCCellType_openMode) {
        value = bleDeviceStatus.openMode;
    }if (type == HXSystemParametersVCCellType_normallyOpenMode) {
        value = bleDeviceStatus.normallyOpenMode;
    }if (type == HXSystemParametersVCCellType_volumeEnable) {
        value = bleDeviceStatus.volumeEnable;
    }if (type == HXSystemParametersVCCellType_systemVolume) {
        value = bleDeviceStatus.systemVolume;
    }if (type == HXSystemParametersVCCellType_shackleAlarmEnable) {
        value = bleDeviceStatus.shackleAlarmEnable;
    }if (type == HXSystemParametersVCCellType_lockCylinderAlarmEnable) {
        value = bleDeviceStatus.lockCylinderAlarmEnable;
    }if (type == HXSystemParametersVCCellType_antiLockEnable) {
        value = bleDeviceStatus.antiLockEnable;
    }if (type == HXSystemParametersVCCellType_lockCoverAlarmEnable) {
        value = bleDeviceStatus.lockCoverAlarmEnable;
    }if (type == HXSystemParametersVCCellType_systemLanguage) {
        value = bleDeviceStatus.systemLanguage;
    }
    return value;
}


@end
