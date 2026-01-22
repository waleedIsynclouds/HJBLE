//
//  HXOperationRecordListVC.m
//  HXJBLESDKDemo
//
//  Created by JQ on 2019/5/30.
//  Copyright © 2019 JQ. All rights reserved.
//

#import "HXOperationRecordListVC.h"
#import "HXAddView.h"
#import <HXJBLESDK/HXBluetoothLockHelper.h>
#import "HXResolutionFunc.h"
#import "HXRecordCellModel.h"

@interface HXOperationRecordListVC ()

@property (nonatomic, strong) HXAddView *emptyView;

@property (nonatomic, assign) int totalCount;
@property (nonatomic, assign) int startIndex;

@property (nonatomic, strong) NSMutableArray *recordArray;

/**
 门锁记录
 1：表示第一代门锁操作记录
 2：表示第二代门锁操作记录
 */
@property (nonatomic, assign) int logVersion;

@end

@implementation HXOperationRecordListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _recordArray = [[NSMutableArray alloc] init];
    [self refreshUI];
}

- (void)refreshUI
{
    if (self.dataArray.count == 0) {
        self.emptyView.hidden = NO;
        setNaviBarRightTitleButton(nil, self, nil);
        self.view.backgroundColor = [UIColor whiteColor];
        self.navigationItem.title = NSLocalizedString(@"Operation record", @"操作记录");
    }else {
        _emptyView.hidden = YES;
        setNaviBarRightSystemButton(UIBarButtonSystemItemRefresh, self, @selector(refresh));
        self.view.backgroundColor = RGB(239, 239, 245);
        self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"Operation record (%d)", @"操作记录(%d)"),(int)self.dataArray.count];
    }
    [self.tableView reloadData];
}

- (HXAddView *)emptyView
{
    if (!_emptyView) {
        _emptyView = [[HXAddView alloc] initWithFrame:CGRectMake(0, 0, QScreenWidth, QScreenHeight-QNavigationBarHeight) title:NSLocalizedString(@"Synchronize all operation records", @"同步所有操作记录")];
        [_emptyView btnAddTarget:self action:@selector(refresh)];
        [self.view addSubview:_emptyView];
    }
    return _emptyView;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HXRecordCellModel *cellModel = [self.dataArray objectAtIndex:indexPath.row];
    return cellModel.cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"operationRecordListCellReuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:17];
        cell.textLabel.numberOfLines = 0;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
        cell.detailTextLabel.textColor = RGB(179, 179, 179);
    }
    HXRecordCellModel *cellModel = [self.dataArray objectAtIndex:indexPath.row];
    cell.textLabel.text = cellModel.title;
    cell.detailTextLabel.text = cellModel.details;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)refresh
{
    [SHCommonFunc showAlertViewWithTitle:NSLocalizedString(@"Synchronize all operation records", @"向蓝牙锁同步所有操作记录") message:nil btn1Title:NSLocalizedString(@"Cancel", @"取消") btn2Title:NSLocalizedString(@"Confirm", @"确定") btn1Block:nil btn2Block:^{
        __weak typeof(self)wself = self;
        showAlertView(NSLocalizedString(@"Fetching the total number of operation records...", @"正在获取操作记录总数..."), self);
        [HXBluetoothLockHelper getOperationRecordCountWithLockMac:self.bleDevice.lockMac completionBlock:^(KSHStatusCode statusCode, NSString *reason, int total) {
            if (statusCode == KSHStatusCode_Success) {
                wself.totalCount = total;
                if (total > 0) {
                    [wself.recordArray removeAllObjects];
                    wself.startIndex = 0;
                    [wself recursion];
                }else {
                    showDurationAlertView(NSLocalizedString(@"No records", @"暂无记录"), wself, 2);
                }
            }else {
                NSString *tips = [NSString stringWithFormat:@"%@[%ld]", reason, (long)statusCode];
                showDurationAlertView(tips, wself, 2);
            }
        }];
    } animated:YES ctl:self];
}

- (void)recursion
{
    __weak typeof(self)wself = self;
    self.logVersion = 1;
    if ((self.bleDevice.menuFeature & kHXMenuFeature_supportSecondEdition) == kHXMenuFeature_supportSecondEdition) {
        self.logVersion = 2;
    }
    [HXBluetoothLockHelper getOperationRecordListWithLockMac:self.bleDevice.lockMac startIndex:self.startIndex count:10 logVersion:self.logVersion completionBlock:^(KSHStatusCode statusCode, NSString *reason, NSArray *logArray, BOOL moreData, int logVersion) {
        
        if (statusCode == KSHStatusCode_Success) {
            BOOL isNull = YES;//应对异常出错的情况
            if (logArray.count > 0) {
                [wself.recordArray addObjectsFromArray:logArray];
                isNull = NO;
                wself.startIndex += (int)logArray.count;
            }
            if (!moreData) {
                //本次同步完成
                if ((wself.startIndex >= wself.totalCount) || isNull) {
                    [wself dataArrayFromRecordArray:wself.recordArray];
                    [wself refreshUI];
                    NSString *tips = [NSString stringWithFormat:NSLocalizedString(@"All records have been synchronized (%d/%d)", @"所有记录同步完成（%d/%d）"), (int)wself.recordArray.count, wself.totalCount];
                    showDurationAlertView(tips, wself, 1.5);
                }else {
                    //继续递归获取更多数据
                    [wself recursion];
                }
                
            }else {
                //本次同步数据分包返回，后续还有数据返回
                NSString *tips = [NSString stringWithFormat:NSLocalizedString(@"Synchronizing records... (%d/%d)", @"同步记录中...（%d/%d）"), (int)wself.recordArray.count, wself.totalCount];
                showAlertView(tips, wself);
            }
            
        }else {
            if (wself.recordArray.count > 0) {
                [wself dataArrayFromRecordArray:wself.recordArray];
            }
            [wself refreshUI];
            NSString *tips = bleCommonTips(reason, statusCode);
            showDurationAlertView(tips, wself, 2);
        }
    }];
}

- (void)dataArrayFromRecordArray:(NSArray *)recordArray
{
    [self.dataArray removeAllObjects];
    if (self.logVersion == 1) {//第一代门锁操作记录
        for (HXRecordBaseModel *recordModel in recordArray) {
            HXRecordCellModel *cellModel = [[HXRecordCellModel alloc] init];
            cellModel.title = [self parsingOperationRecorModel:recordModel];
            cellModel.cellHeight = stringSize(cellModel.title, CGSizeMake(QScreenWidth-30, 1000), 17).height + 50;
            cellModel.details = [HXResolutionFunc timeFromTimestamp:recordModel.recordTime];
            [self.dataArray addObject:cellModel];
        }
    }else if (self.logVersion == 2) {//第二代门锁操作记录
        for (HXRecord2BaseModel *recordModel in recordArray) {
            HXRecordCellModel *cellModel = [[HXRecordCellModel alloc] init];
            // 待解析TODO
//            cellModel.title = [self parsingOperationRecorModel:recordModel];
//            cellModel.cellHeight = stringSize(cellModel.title, CGSizeMake(QScreenWidth-30, 1000), 17).height + 50;
//            cellModel.details = [HXResolutionFunc timeFromTimestamp:recordModel.recordTime];
//            [self.dataArray addObject:cellModel];
        }
    }
    
}

- (NSString *)parsingOperationRecorModel:(HXRecordBaseModel *)baseModel
{
    NSString *tips = @"";
    kSHBLEReadRecordType recordType = baseModel.recordType;
    switch (recordType) {
        case kSHBLEReadRecordType_addKey:{
            HXRecordAddKeyModel *model = (HXRecordAddKeyModel *)baseModel;
            tips = [NSString stringWithFormat:NSLocalizedString(@"User %d added a %@ key%d", @"用户%d添加了一个%@钥匙%d"), model.operKeyGroupId, [HXResolutionFunc keyNameWithType:model.keyType], model.addLockKeyId];
            break;
        }
        case kSHBLEReadRecordType_alarm:{
            HXRecordAlarmModel *model = (HXRecordAlarmModel *)baseModel;
            tips = [HXResolutionFunc alarmString:model];
            break;
        }
        case kSHBLEReadRecordType_antiLock:{
            HXRecordAntiLockModel *model = (HXRecordAntiLockModel *)baseModel;
            tips = model.antiLock==0?NSLocalizedString(@"Bluetooth lock has been released", @"蓝牙锁反锁已解除"):NSLocalizedString(@"Bluetooth lock is locked", @"蓝牙锁已反锁");
            break;
        }
        case kSHBLEReadRecordType_armDisarm:{
            HXRecordArmDisarmModel *model = (HXRecordArmDisarmModel *)baseModel;
            tips = model.arm==0?NSLocalizedString(@"Bluetooth lock is disarmed", @"蓝牙锁已撤防"):NSLocalizedString(@"Bluetooth lock is armed", @"蓝牙锁已布防");
            break;
        }
        case kSHBLEReadRecordType_closeLock:{
            HXRecordCloseLockModel *model = (HXRecordCloseLockModel *)baseModel;
            tips = model.operLockKeyId==0?NSLocalizedString(@"Bluetooth lock is close", @"蓝牙锁已关闭"):[NSString stringWithFormat:NSLocalizedString(@"The user holding key %d closed the door lock", @"持有钥匙%d的用户关闭了门锁"),model.operLockKeyId];
            break;
        }
        case kSHBLEReadRecordType_deleteGroupKey:{
            HXRecordDeleteGroupKeyModel *model = (HXRecordDeleteGroupKeyModel *)baseModel;
            tips = [self deleteGroupKeyString:model];
            break;
        }
        case kSHBLEReadRecordType_deleteKey:{
            HXRecordDeleteKeyModel *model = (HXRecordDeleteKeyModel *)baseModel;
            tips = [NSString stringWithFormat:NSLocalizedString(@"User %d deleted key %d", @"用户%d删除了钥匙%d"), model.operKeyGroupId, model.delLockKeyId];
            break;
        }
        case kSHBLEReadRecordType_keyEnable:{
            HXRecordKeyEnableModel *model = (HXRecordKeyEnableModel *)baseModel;
            tips = [self keyEnableString:model];
            break;
        }
        case kSHBLEReadRecordType_modifyKey:{
            HXRecordModifyKeyModel *model = (HXRecordModifyKeyModel *)baseModel;
            tips = [NSString stringWithFormat:NSLocalizedString(@"%@ type key %d was modified by user %d", @"%@类型的钥匙%d被用户%d修改"), [HXResolutionFunc keyNameWithType:model.modifyLockKeyType], model.modifyLockKeyId, model.operKeyGroupId];
            break;
        }
        case kSHBLEReadRecordType_modifyKeyTime:{
            HXRecordModifyKeyTimeModel *model = (HXRecordModifyKeyTimeModel *)baseModel;
            tips = [self modifyKeyTimeString:model];
            break;
        }
        case kSHBLEReadRecordType_setSysPram:{
            HXRecordSetSysPramModel *model = (HXRecordSetSysPramModel *)baseModel;
            tips = [self setSysPramString:model];
            break;
        }
        case kSHBLEReadRecordType_unlock:{
            HXRecordUnlockModel *model = (HXRecordUnlockModel *)baseModel;
            tips = [NSString stringWithFormat:NSLocalizedString(@"User %d opened the Bluetooth lock", @"用户%d打开了蓝牙锁"), model.operKeyGroupId1];
            break;
        }
        case kSHBLEReadRecordType_verifyPassword:{
            HXRecordVerifyPwModel *model = (HXRecordVerifyPwModel *)baseModel;
            tips = [NSString stringWithFormat:NSLocalizedString(@"User %d verifies the key %d: %@", @"用户%d对钥匙%d进行验证：%@"), model.operKeyGroupId, model.lockKeyId, model.isPass==1?NSLocalizedString(@"Pass", @"通过"):NSLocalizedString(@"No pass", @"不通过")];
            break;
        }
        case kSHBLEReadRecordType_synTime: {
            tips = NSLocalizedString(@"Bluetooth lock to synchronize phone time", @"蓝牙锁同步手机时间");
            break;
        }
        case kSHBLEReadRecordType_doorbell:{
            tips = NSLocalizedString(@"Someone presses door bell", @"有人按门玲");
            break;
        }
        default:
            break;
    }
    return tips;
}


- (NSString *)deleteGroupKeyString:(HXRecordDeleteGroupKeyModel *)model
{
    NSString *tips = @"";
    if (model.deleteMode == 3) {
        tips = [NSString stringWithFormat:NSLocalizedString(@"All keys of user %d are deleted by user %d", @"用户%d的所有钥匙被用户%d删除"),model.delKeyGroupId, model.operKeyGroupId];
    }else if (model.deleteMode == 1) {
        NSString *keyNames = [self keyNamesWithKeyTypes:model.delKeyType];
        tips = [NSString stringWithFormat:NSLocalizedString(@"All keys of type %@ in the Bluetooth lock are deleted by user %d", @"蓝牙锁中所有%@类型的钥匙被用户%d删除"), keyNames, model.operKeyGroupId];
    }
    return tips;
}

- (NSString *)keyEnableString:(HXRecordKeyEnableModel *)model
{
    NSString *tips = @"";
    
    if (model.operMode == 1) {
        tips = [NSString stringWithFormat:NSLocalizedString(@"Key %d is used by user %d %@", @"钥匙%d被用户%d%@"), model.modifyLockKeyId, model.operKeyGroupId, model.enable==1?NSLocalizedString(@"Enable", @"激活"):NSLocalizedString(@"Disable", @"禁用")];
    }else if (model.operMode == 2) {
        if ((model.modifyKeyTypes & KSHKeyType_Fingerprint) == KSHKeyType_Fingerprint) {
            if ((model.enable & KSHKeyType_Fingerprint) == KSHKeyType_Fingerprint) {
                tips = [tips stringByAppendingString:NSLocalizedString(@"Fingerprint enable ", @"激活了指纹 ")];
            }else {
                tips = [tips stringByAppendingString:NSLocalizedString(@"Fingerprint is disabled ", @"禁用了指纹 ")];
            }
        }
        if ((model.modifyKeyTypes & KSHKeyType_Password) == KSHKeyType_Password) {
            if ((model.enable & KSHKeyType_Password) == KSHKeyType_Password) {
                tips = [tips stringByAppendingString:NSLocalizedString(@"Password enable ", @"激活了密码 ")];
            }else {
                tips = [tips stringByAppendingString:NSLocalizedString(@"Password disabled ", @"禁用了密码 ")];
            }
        }
        if ((model.modifyKeyTypes & KSHKeyType_Card) == KSHKeyType_Card) {
            if ((model.enable & KSHKeyType_Card) == KSHKeyType_Card) {
                tips = [tips stringByAppendingString:NSLocalizedString(@"Card enable ", @"激活了卡片 ")];
            }else {
                tips = [tips stringByAppendingString:NSLocalizedString(@"Card disabled ", @"禁用了卡片 ")];
            }
        }
        if ((model.modifyKeyTypes & KSHKeyType_RemoteControl) == KSHKeyType_RemoteControl) {
            if ((model.enable & KSHKeyType_RemoteControl) == KSHKeyType_RemoteControl) {
                tips = [tips stringByAppendingString:NSLocalizedString(@"Remote control enable ", @"激活了遥控 ")];
            }else {
                tips = [tips stringByAppendingString:NSLocalizedString(@"Remote control disabled ", @"禁用了遥控 ")];
            }
        }
        tips = [tips stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        tips = [NSString stringWithFormat:NSLocalizedString(@"User %d %@", @"用户%d%@"), model.operKeyGroupId, tips];
        
    }else if (model.operMode == 3) {
        tips = [NSString stringWithFormat:NSLocalizedString(@"All keys of user %d are %@", @"用户%d的所有钥匙被%@"), model.operKeyGroupId, model.enable==1?NSLocalizedString(@"Enable", @"激活"):NSLocalizedString(@"Disable", @"禁用")];
    }
    return tips;
}

- (NSString *)modifyKeyTimeString:(HXRecordModifyKeyTimeModel *)model
{
    NSString *tips = @"";
    if (model.changeMode == 1) {
        tips = [NSString stringWithFormat:NSLocalizedString(@"User %d modified the validity period of the key %d", @"用户%d修改了钥匙%d的有效期"), model.operKeyGroupId, model.changeId];
    }else if (model.changeMode == 2) {
        tips = [NSString stringWithFormat:NSLocalizedString(@"User %d modified the validity period of user %d", @"用户%d修改了用户%d的有效期"), model.operKeyGroupId, model.changeId];
    }
    return tips;
}

- (NSString *)setSysPramString:(HXRecordSetSysPramModel *)model
{
    NSMutableString *tips = [[NSMutableString alloc] initWithFormat:NSLocalizedString(@"User %d has set system parameters\n", @"用户%d设置了系统参数\n"), model.operKeyGroupId];
    if (model.openMode == 1) {
        [tips appendString:NSLocalizedString(@"Unlock mode: single unlock\n", @"开锁模式：单一开锁\n")];
    }else if (model.openMode == 2) {
        [tips appendString:NSLocalizedString(@"Unlock Mode: Combination Unlock\n", @"开锁模式：组合开锁\n")];
    }
    if (model.normallyOpenMode == 1) {
        [tips appendString:NSLocalizedString(@"Normally open mode: enabled\n", @"常开模式：启用\n")];
    }else if (model.normallyOpenMode == 2) {
        [tips appendString:NSLocalizedString(@"Normally open mode: disable\n", @"常开模式：关闭\n")];
    }
    if (model.volumeEnable == 1) {
        [tips appendString:NSLocalizedString(@"Door opening voice: enabled\n", @"开门语音：打开\n")];
    }else if (model.volumeEnable == 2) {
        [tips appendString:NSLocalizedString(@"Door opening voice: disable\n", @"开门语音：关闭\n")];
    }
    if (model.systemVolume != 0) {
        [tips appendFormat:NSLocalizedString(@"System volume: %d", @"系统音量：%d"),model.systemVolume];
    }
    if (model.shackleAlarmEnable == 1) {
        [tips appendString:NSLocalizedString(@"Anti-pry alarm: enabled\n", @"防撬报警：启动\n")];
    }else if (model.shackleAlarmEnable == 2) {
        [tips appendString:NSLocalizedString(@"Anti-pry alarm: disable\n", @"防撬报警：关闭\n")];
    }
    if (model.lockCylinderAlarmEnable == 1) {
        [tips appendString:NSLocalizedString(@"Lock core alarm: enable\n", @"锁芯报警：启动\n")];
    }else if (model.lockCylinderAlarmEnable == 2) {
        [tips appendString:NSLocalizedString(@"Lock core alarm: disable\n", @"锁芯报警：关闭\n")];
    }
    if (model.antiLockEnable == 1) {
        [tips appendString:NSLocalizedString(@"Anti-lock function: enable\n", @"反锁功能：打开\n")];
    }else if (model.antiLockEnable == 2) {
        [tips appendString:NSLocalizedString(@"Anti-lock function: disable\n", @"反锁功能：关闭\n")];
    }
    if (model.lockCoverAlarmEnable == 1) {
        [tips appendString:NSLocalizedString(@"Lock cover alarm: enable\n", @"锁头盖报警：启动\n")];
    }else if (model.lockCoverAlarmEnable == 2) {
        [tips appendString:NSLocalizedString(@"Lock cover alarm: disable\n", @"锁头盖报警：关闭\n")];
    }
    if (model.systemLanguage != 0) {
        NSString *systemLanguage = [HXResolutionFunc systemLanguageString:model.systemLanguage];
        [tips appendFormat:NSLocalizedString(@"System volume: %@\n", @"系统音量：%@\n"),systemLanguage];
    }
    [tips setString:[tips stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    return tips;
}


- (NSString *)keyNamesWithKeyTypes:(KSHKeyType)keyTypes
{
    NSString *keyNames = @"";
    if ((keyTypes & KSHKeyType_Fingerprint) == KSHKeyType_Fingerprint) {
        keyNames = [keyNames stringByAppendingString:NSLocalizedString(@"fingerprint ", @"指纹 ")];
    }
    if ((keyTypes & KSHKeyType_Password) == KSHKeyType_Password) {
        keyNames = [keyNames stringByAppendingString:NSLocalizedString(@"password ", @"密码 ")];
    }
    if ((keyTypes & KSHKeyType_Card) == KSHKeyType_Card) {
        keyNames = [keyNames stringByAppendingString:NSLocalizedString(@"card ", @"卡片 ")];
    }
    if ((keyTypes & KSHKeyType_RemoteControl) == KSHKeyType_RemoteControl) {
        keyNames = [keyNames stringByAppendingString:NSLocalizedString(@"remote control ", @"遥控 ")];
    }
    keyNames = [keyNames stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return keyNames;
}


@end
