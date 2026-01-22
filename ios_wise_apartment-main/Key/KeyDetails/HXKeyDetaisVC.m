//
//  HXKeyDetaisVC.m
//  HXJBLESDKDemo
//
//  Created by JQ on 2019/5/29.
//  Copyright © 2019 JQ. All rights reserved.
//

#import "HXKeyDetaisVC.h"
#import "HXSectionModel.h"
#import "HXTitleCellModel.h"
#import "HXCenterTitleCell.h"
#import <HXJBLESDK/HXBluetoothLockHelper.h>
#import "HXCoreDataStackHelper.h"
#import "HXResolutionFunc.h"

typedef NS_ENUM(NSInteger, HXKeyDetaisVCCellType) {
    HXKeyDetaisVCCellType_user,
    HXKeyDetaisVCCellType_lockKeyId,
    HXKeyDetaisVCCellType_keyType,
    HXKeyDetaisVCCellType_Forever,
    HXKeyDetaisVCCellType_validStartTime,
    HXKeyDetaisVCCellType_validEndTime,
    HXKeyDetaisVCCellType_validNumber,
    HXKeyDetaisVCCellType_weeks,
    HXKeyDetaisVCCellType_dayStartTimes,
    HXKeyDetaisVCCellType_dayEndTimes,
    HXKeyDetaisVCCellType_modifyKeyTime,
    HXKeyDetaisVCCellType_modifyPassword,
    HXKeyDetaisVCCellType_keyStatus,
    HXKeyDetaisVCCellType_delete
};

@interface HXKeyDetaisVC ()

@property (nonatomic, strong) HXKeyModel *bleKey;

@property (nonatomic, assign) int unknown;

@end

@implementation HXKeyDetaisVC

- (instancetype)initWithBLEDevice:(HXBLEDevice *)bleDevice bleKey:(HXKeyModel *)bleKey
{
    self = [super initWithBLEDevice:bleDevice];
    if (self) {
        self.bleKey = bleKey;
        _unknown = -1;//用于钥匙激活后无法确定其真实的有效使用次数。建议服务器将钥匙信息保存，以便App禁用钥匙，之后激活能够拿到有效使用次数。
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"Key details", @"钥匙详情");
    [self loadData];
}

- (void)loadData
{
    [self.dataArray removeAllObjects];
    
    HXSectionModel *section1 = [self addSection];
    [self section:section1 addCellWithType:HXKeyDetaisVCCellType_user];
    
    HXSectionModel *section2 = [self addSection];
    [self section:section2 addCellWithType:HXKeyDetaisVCCellType_lockKeyId];
    [self section:section2 addCellWithType:HXKeyDetaisVCCellType_keyType];
    
    HXSectionModel *section3 = [self addSection];
    [self section:section3 addCellWithType:HXKeyDetaisVCCellType_keyStatus];
    
    HXSectionModel *section4 = [self addSection];
    if (self.bleKey.validStartTime == 0 && self.bleKey.validEndTime == 0xFFFFFFFF) {
        //有效时间段为永久有效
        [self section:section4 addCellWithType:HXKeyDetaisVCCellType_Forever];
    }else {
        [self section:section4 addCellWithType:HXKeyDetaisVCCellType_validStartTime];
        [self section:section4 addCellWithType:HXKeyDetaisVCCellType_validEndTime];
    }
    if (self.bleKey.authMode == 2) {
        //周期有效
        [self section:section4 addCellWithType:HXKeyDetaisVCCellType_weeks];
        [self section:section4 addCellWithType:HXKeyDetaisVCCellType_dayStartTimes];
        [self section:section4 addCellWithType:HXKeyDetaisVCCellType_dayEndTimes];
    }
    if (self.bleKey.validNumber != 0 &&
        self.bleKey.validNumber != _unknown) {
        //0表示禁用
        [self section:section4 addCellWithType:HXKeyDetaisVCCellType_validNumber];
    }
    if (self.bleDevice.bleProtocolVersion >= 13) {
        [self section:section4 addCellWithType:HXKeyDetaisVCCellType_modifyKeyTime];
    }
    
    if (self.bleKey.keyType == KSHKeyType_Password) {
        HXSectionModel *section5 = [self addSection];
        [self section:section5 addCellWithType:HXKeyDetaisVCCellType_modifyPassword];
    }
    
    HXSectionModel *section5 = [self addSection];
    [self section:section5 addCellWithType:HXKeyDetaisVCCellType_delete];
    
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
    HXKeyDetaisVCCellType type = cellModel.type;
    if (type == HXKeyDetaisVCCellType_delete) {
        HXCenterTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:[HXCenterTitleCell cellReuseIdentifier]];
        if (!cell) {
            cell = [[HXCenterTitleCell alloc] init];
            cell.textLabel.textColor = [UIColor redColor];
        }
        cell.textLabel.text = [self titleWithType:type];
        return cell;
    }else {
        static NSString *reuseIdentifier = @"keyDetailsCellReuseIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
        }
        if (type == HXKeyDetaisVCCellType_modifyPassword||
            type == HXKeyDetaisVCCellType_modifyKeyTime ||
            type == HXKeyDetaisVCCellType_keyStatus) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        cell.textLabel.text = [self titleWithType:type];
        cell.detailTextLabel.text = [self detailsWithType:type];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    HXSectionModel *sectionModel = [self.dataArray objectAtIndex:indexPath.section];
    HXTitleCellModel *cellModel = [sectionModel cellModelAtIndex:indexPath.row];
    if (cellModel.type == HXKeyDetaisVCCellType_delete) {
        [self deleteKey];
    }else if (cellModel.type == HXKeyDetaisVCCellType_modifyPassword) {
        [self modifyPassword];
    }else if (cellModel.type == HXKeyDetaisVCCellType_modifyKeyTime) {
        [self modifyKeyTime];
    }else if (cellModel.type == HXKeyDetaisVCCellType_keyStatus) {
        [self setKeyStatus];
    }
}

- (void)deleteKey
{
    __weak typeof(self)wself = self;
    HXDeleteKeyParams *params = [[HXDeleteKeyParams alloc] init];
    params.lockMac = self.bleDevice.lockMac;
    params.deleteMode = 0;
    params.lockKeyId = self.bleKey.lockKeyId;
    params.keyType = self.bleKey.keyType;
    showAlertView(NSLocalizedString(@"Deleting, please wait...", @"删除中，请稍后..."), self);
    [HXBluetoothLockHelper deleteKey:params completionBlock:^(KSHStatusCode statusCode, NSString *reason) {
        if (statusCode == KSHStatusCode_Success) {
            [HXCoreDataStackHelper deleteKeyWithLockMac:wself.bleDevice.lockMac lockKeyId:wself.bleKey.lockKeyId];
            showCompletionBlockAlertView(NSLocalizedString(@"successfully deleted", @"删除成功"), wself, 1.5, ^{
                [wself.navigationController popViewControllerAnimated:YES];
            });
        }else {
            NSString *tips = bleCommonTips(reason, statusCode);
            showDurationAlertView(tips, wself, 2);
        }
    }];
}

- (void)modifyPassword
{
    [SHCommonFunc showTextFieldAlertViewWithTitle:NSLocalizedString(@"Modify Password", @"修改密码") message:NSLocalizedString(@"Password length is 6-12 digits", @"密码长度为6～12位的数字") confirmTitle:NSLocalizedString(@"Modify", @"修改") textFieldConfigureBlock:^(UITextField *textField) {
        textField.keyboardType = UIKeyboardTypeNumberPad;
    } confirmBlock:^(UITextField *textField) {
        if (textField.text.length < 6 || textField.text.length > 12) {
            showDurationAlertView(NSLocalizedString(@"The password length requires 6-12 digits!", @"密码长度要求6～12位！"), self, 1.5);
            return;
        }
        __weak typeof(self)wself = self;
        showAlertView(NSLocalizedString(@"Modifying the password, please wait...", @"修改密码中，请稍后..."), self);
        [HXBluetoothLockHelper modifyKeyPassword:textField.text lockKeyId:self.bleKey.lockKeyId locMac:self.bleKey.lockMac completionBlock:^(KSHStatusCode statusCode, NSString *reason) {
            if (statusCode == KSHStatusCode_Success) {
                NSString *tips = [NSString stringWithFormat:NSLocalizedString(@"Password: %@, please keep the password properly by yourself", @"密码：%@，请自行妥善保管该密码"),textField.text];
                [SHCommonFunc showAlertViewWithTitle:NSLocalizedString(@"successfully modify password", @"修改密码成功") message:tips btnTitle:NSLocalizedString(@"Got it", @"知道了") btnBlock:nil ctl:wself];
            }else {
                NSString *tips = bleCommonTips(reason, statusCode);
                showDurationAlertView(tips, wself, 2);
            }
        }];
    } ctl:self];
}

- (void)modifyKeyTime
{
    NSMutableString *message = [[NSMutableString alloc] init];
    HXModifyKeyTimeParams *params = [[HXModifyKeyTimeParams alloc] init];
    params.lockMac = self.bleKey.lockMac;
    params.changeMode = 1;
    params.changeId = self.bleKey.lockKeyId;
    params.vaildNumber = 255;
    //365天有效
    params.validStartTime = [[NSDate date] timeIntervalSince1970];
    params.validEndTime = params.validStartTime+(365*24*60*60);
    [message appendFormat:NSLocalizedString(@"The key validity period is changed from \n%@ to\n%@\n", @"钥匙有效期改为\n%@至\n%@\n"),[HXResolutionFunc timeFromTimestamp:params.validStartTime],[HXResolutionFunc timeFromTimestamp:params.validEndTime]];
    if (self.bleKey.authMode == 2) {
        params.authMode = 1;
        [message appendFormat:NSLocalizedString(@"Cancel cycle repeat", @"取消周期重复")];
    }else {
        params.authMode = 2;
        params.weeks = kSHWeek_saturday|kSHWeek_sunday;
        [message appendFormat:NSLocalizedString(@"Cycle repeat: Saturday, Sunday\n", @"周期重复：周六、周日\n")];
        //00:00 ~ 23:59
        params.dayStartTimes = 0;
        params.dayEndTimes = 23*60 + 59;
        [message appendFormat:NSLocalizedString(@"Effective daily time: %@\n", @"每日生效时间：%@\n"), [HXResolutionFunc hhmmFromMinute:params.dayStartTimes]];
        [message appendFormat:NSLocalizedString(@"Daily expiration time: %@\n", @"每日失效时间：%@\n"), [HXResolutionFunc hhmmFromMinute:params.dayEndTimes]];
    }
    [SHCommonFunc showAlertViewWithTitle:NSLocalizedString(@"Modify the key validity period", @"修改钥匙有效期") message:message btn1Title:NSLocalizedString(@"Cancel", @"取消") btn2Title:NSLocalizedString(@"Modify", @"修改") btn1Block:nil btn2Block:^{
        __weak typeof(self)wself = self;
        showAlertView(NSLocalizedString(@"Modifying, please wait...", @"修改中，请稍后..."), self);
        [HXBluetoothLockHelper modifyKeyTime:params completionBlock:^(KSHStatusCode statusCode, NSString *reason) {
            if (statusCode == KSHStatusCode_Success) {
                showDurationAlertView(NSLocalizedString(@"Successfully", @"成功"), wself, 1.5);
                wself.bleKey.validNumber = params.vaildNumber;
                wself.bleKey.validStartTime = params.validStartTime;
                wself.bleKey.validEndTime = params.validEndTime;
                wself.bleKey.authMode = params.authMode;
                wself.bleKey.weeks = params.weeks;
                wself.bleKey.dayStartTimes = params.dayStartTimes;
                wself.bleKey.dayEndTimes = params.dayEndTimes;
                [HXCoreDataStackHelper saveKey:wself.bleKey];
                [wself loadData];
                
            }else {
                NSString *tips = bleCommonTips(reason, statusCode);
                showDurationAlertView(tips, wself, 2);
            }
        }];
    } animated:YES ctl:self];
}

- (void)setKeyStatus
{
    HXSetKeyEnableParams *params = [[HXSetKeyEnableParams alloc] init];
    params.lockMac = self.bleKey.lockMac;
    params.operMode = 1;
    params.lockKeyId = self.bleKey.lockKeyId;
    params.enable = self.bleKey.validNumber==0?1:0;
    NSString *title = params.enable==1?NSLocalizedString(@"Enable the key?", @"激活钥匙？"):NSLocalizedString(@"Disable the key?", @"禁用钥匙？");
    [SHCommonFunc showAlertViewWithTitle:title message:nil btn1Title:NSLocalizedString(@"Cancel", @"取消") btn2Title:NSLocalizedString(@"Confirm", @"确定") btn1Block:nil btn2Block:^{
        __weak typeof(self)wself = self;
        showAlertView(NSLocalizedString(@"Setting up, please wait...", @"设置中，请稍后..."), self);
        [HXBluetoothLockHelper setKeyEnable:params completionBlock:^(KSHStatusCode statusCode, NSString *reason) {
            if (statusCode == KSHStatusCode_Success) {
                showDurationAlertView(NSLocalizedString(@"success", @"成功"), wself, 1.5);
                if (params.enable) {
                    wself.bleKey.validNumber = wself.unknown;
                }else {
                    wself.bleKey.validNumber = 0;
                }
                [HXCoreDataStackHelper saveKey:wself.bleKey];
                [wself loadData];
                
            }else {
                NSString *tips = bleCommonTips(reason, statusCode);
                showDurationAlertView(tips, wself, 2);
            }
        }];
    } animated:YES ctl:self];
}

#pragma mark -TableViewCell数据处理
- (HXSectionModel *)addSection
{
    HXSectionModel *section = [[HXSectionModel alloc] init];
    [self.dataArray addObject:section];
    return section;
}

- (void)section:(HXSectionModel *)section addCellWithType:(HXKeyDetaisVCCellType)type
{
    NSString *title = [self titleWithType:type];
    HXTitleCellModel *cellModel = [[HXTitleCellModel alloc] initWithTitle:title type:type];
    cellModel.details = [self detailsWithType:type];
    [section addCellModel:cellModel];
}

- (NSString *)titleWithType:(HXKeyDetaisVCCellType)type
{
    NSString *title;
    if (type == HXKeyDetaisVCCellType_user) {
        title = NSLocalizedString(@"User", @"用户");
    }else if (type == HXKeyDetaisVCCellType_lockKeyId) {
        title = NSLocalizedString(@"Key Id", @"钥匙编号");
    }else if (type == HXKeyDetaisVCCellType_keyType) {
        title = NSLocalizedString(@"Key type", @"钥匙类型");
    }else if (type == HXKeyDetaisVCCellType_keyStatus) {
        title = NSLocalizedString(@"Key status", @"钥匙状态");
    }else if (type == HXKeyDetaisVCCellType_Forever) {
        title = NSLocalizedString(@"Valid period", @"有效期");
    }else if (type == HXKeyDetaisVCCellType_validStartTime) {
        title = NSLocalizedString(@"Valid start time", @"有效期开始时间");
    }else if (type == HXKeyDetaisVCCellType_validEndTime) {
        title = NSLocalizedString(@"Valid end time", @"有效期结束时间");
    }else if (type == HXKeyDetaisVCCellType_validNumber) {
        title = NSLocalizedString(@"Effective use times", @"有效使用次数");
    }else if (type == HXKeyDetaisVCCellType_weeks) {
        title = NSLocalizedString(@"Cycle repeat", @"周期重复");
    }else if (type == HXKeyDetaisVCCellType_dayStartTimes) {
        title = NSLocalizedString(@"Daily start time", @"每日生效时间");
    }else if (type == HXKeyDetaisVCCellType_dayEndTimes) {
        title = NSLocalizedString(@"Daily end time", @"每日结束时间");
    }else if (type == HXKeyDetaisVCCellType_modifyKeyTime) {
        title = NSLocalizedString(@"Modify the validity period", @"修改有效期");
    }else if (type == HXKeyDetaisVCCellType_delete) {
        title = NSLocalizedString(@"Delete", @"删除");
    }else if (type == HXKeyDetaisVCCellType_modifyPassword) {
        title = NSLocalizedString(@"Modify Password", @"修改密码");
    }else {
        title = @"";
    }
    return title;
}

- (NSString *)detailsWithType:(HXKeyDetaisVCCellType)type
{
    NSString *title;
    if (type == HXKeyDetaisVCCellType_user) {
        title = @(self.bleKey.keyGroupId).stringValue;
        
    }else if (type == HXKeyDetaisVCCellType_lockKeyId) {
        title = @(self.bleKey.lockKeyId).stringValue;
        
    }else if (type == HXKeyDetaisVCCellType_keyType) {
        title = [HXResolutionFunc keyNameWithType:self.bleKey.keyType];
        
    }else if (type == HXKeyDetaisVCCellType_keyStatus) {
        title = self.bleKey.validNumber == 0?NSLocalizedString(@"Disable", @"禁用"):NSLocalizedString(@"Normal", @"正常");

    }else if (type == HXKeyDetaisVCCellType_Forever) {
        title = NSLocalizedString(@"Forever", @"永久");
        
    }else if (type == HXKeyDetaisVCCellType_validStartTime) {
        title = [HXResolutionFunc timeFromTimestamp:self.bleKey.validStartTime];
        
    }else if (type == HXKeyDetaisVCCellType_validEndTime) {
        title = [HXResolutionFunc timeFromTimestamp:self.bleKey.validEndTime];
        
    }else if (type == HXKeyDetaisVCCellType_validNumber) {
        title = [HXResolutionFunc validNumberString:self.bleKey.validNumber];
        
    }else if (type == HXKeyDetaisVCCellType_weeks) {
        title = [HXResolutionFunc weeksString:self.bleKey.weeks];
        
    }else if (type == HXKeyDetaisVCCellType_dayStartTimes) {
        title = [HXResolutionFunc hhmmFromMinute:self.bleKey.dayStartTimes];
        
    }else if (type == HXKeyDetaisVCCellType_dayEndTimes) {
        title = [HXResolutionFunc hhmmFromMinute:self.bleKey.dayEndTimes];
        
    }else {
        title = @"";
    }
    return title;
}



@end
