//
//  HXPushEventHelper.m
//  HXJBLESDKDemo
//
//  Created by JQ on 2019/5/30.
//  Copyright © 2019 JQ. All rights reserved.
//

#import "HXPushEventHelper.h"
#import <HXJBLESDK/HXPushEventHeader.h>
#import "HXResolutionFunc.h"

@interface HXPushEventHelper()

@property (nonatomic, strong) NSMutableArray<HXRecordCellModel *> *dataArray;

@end

@implementation HXPushEventHelper

+ (instancetype)sharedPushEventHelper
{
    static HXPushEventHelper *helper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[HXPushEventHelper alloc] init];
    });
    return helper;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dataArray = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushEventNotification:) name:HXPushEventNotification object:nil];
    }
    return self;
}

- (NSArray<HXRecordCellModel *> *)loadDataWithLockMac:(NSString *)lockMac
{
    NSArray *dataArr = nil;
    if (self.dataArray.count > 0 && lockMac) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"obj.lockMac = %@",lockMac];
        NSArray<HXRecordCellModel *> *filteredArr = [self.dataArray filteredArrayUsingPredicate:predicate];
        if (filteredArr.count > 0) {
            dataArr = [filteredArr sortedArrayUsingComparator:^NSComparisonResult(HXRecordCellModel *obj1, HXRecordCellModel *obj2) {
                HXPushEventBase *model1 = obj1.obj;
                HXPushEventBase *model2 = obj2.obj;
                return model1.timestamp < model2.timestamp;
            }];
        }
    }
    return dataArr;
}

- (void)pushEventNotification:(NSNotification *)notification
{
    HXPushEventBase *baseModel = notification.object;
    KSHEventType eventType = baseModel.eventType;
    NSString *tips = @"";
    switch (eventType) {
        case KSHEventType_AddUser:{
            HXPushEventAddKey *model = (HXPushEventAddKey *)baseModel;
            tips = [NSString stringWithFormat:NSLocalizedString(@"User %d added a %@ key %d", @"用户%d添加了一个%@钥匙%d"), model.operKeyGroupId, [HXResolutionFunc keyNameWithType:model.keyType], model.lockKeyId];
            break;
        }
        case KSHEventType_DeleteUser:{
            HXPushEventDeleteKey *model = (HXPushEventDeleteKey *)baseModel;
            tips = [self deleteGroupKeyString:model];
            break;
        }
        case KSHEventType_KeyEnableAndDisable:{
            HXPushEventKeyEnable *model = (HXPushEventKeyEnable *)baseModel;
            tips = [self keyEnableString:model];
            break;
        }
        case KSHEventType_ModifyKeyTime:{
            HXPushEventModifyKeyTimeEvent *model = (HXPushEventModifyKeyTimeEvent *)baseModel;
            tips = [self modifyKeyTimeString:model];
            break;
        }
        case KSHEventType_ChangePassword:{
            HXPushEventModifyPassword *model = (HXPushEventModifyPassword *)baseModel;
            tips = [NSString stringWithFormat:NSLocalizedString(@"%@ type key %d was modified by user %d", @"%@类型的钥匙%d被用户%d修改"), [HXResolutionFunc keyNameWithType:model.modifyLockKeyType], model.modifyLockKeyId, model.operKeyGroupId];
            break;
        }
        case KSHEventType_SystemParameterSetting:{
            HXPushEventSystemParameters *model = (HXPushEventSystemParameters *)baseModel;
            tips = [self setSysPramString:model];
            break;
        }
        case KSHEventType_Unlock:{
            HXPushEventUnlock *model = (HXPushEventUnlock *)baseModel;
            tips = [NSString stringWithFormat:NSLocalizedString(@"User %d opened the Bluetooth lock", @"用户%d打开了蓝牙锁"), model.operKeyGroupId1];
            break;
        }
        default:{
            //HXPushEventCommon *model = (HXPushEventCommon *)baseModel;
            if (eventType == KSHEventType_PickAlarm) {
                tips = NSLocalizedString(@"Lock picking alarm", @"撬锁报警");
            }else if (eventType == KSHEventType_ExcessiveNumError) {
                tips = NSLocalizedString(@"Illegal operation, the system is locked", @"非法操作，系统已锁定");
            }else if (eventType == KSHEventType_Lowpower) {
                tips = NSLocalizedString(@"Low battery alarm, please replace the battery in time", @"低电量报警，请及时更换电池");
            }else if (eventType == KSHEventType_Arm) {
                tips = NSLocalizedString(@"Bluetooth lock is armed", @"蓝牙锁已布防");
            }else if (eventType == KSHEventType_Disarm) {
                tips = NSLocalizedString(@"Bluetooth lock is disarmed", @"蓝牙锁已撤防");
            }else if (eventType == KSHEventType_Hijack) {
                tips = NSLocalizedString(@"Hijacking (duress) unlocking alarm", @"劫持（胁迫）开锁报警");
            }else if (eventType == KSHEventType_doubleLock) {
                tips = NSLocalizedString(@"Bluetooth lock is locked", @"蓝牙锁已反锁");
            }else if (eventType == KSHEventType_doubleLockRemove) {
                tips = NSLocalizedString(@"Bluetooth lock has been released", @"蓝牙锁反锁已解除");
            }else if (eventType == KSHEventType_LockCoreAlarm) {
                tips = NSLocalizedString(@"Lock core alarm", @"撬锁芯报警");
            }else if (eventType == KSHEventType_DoorbellEvent) {
                tips = NSLocalizedString(@"Someone presses Menling", @"有人按门玲");
            }else if (eventType == KSHEventType_FakeLockAlarm) {
                tips = NSLocalizedString(@"False lock alarm (door lock is not closed)", @"假锁报警（门锁未关好）");
            }else if (eventType == KSHEventType_NoClosedDoorAlarm) {
                tips = NSLocalizedString(@"Unclosed door alarm", @"未关门报警");
            }else if (eventType == KSHEventType_DoorLockAlwaysOpen) {
                tips = NSLocalizedString(@"Door lock normally open event", @"门锁常开事件");
            }else if (eventType == KSHEventType_ClosedNormallyOpen) {
                tips = NSLocalizedString(@"The door lock is locked (closed and normally open)", @"门锁已上锁（已关闭常开）");
            }else if (eventType == KSHEventType_DoorLockFailure) {
                tips = NSLocalizedString(@"Lock failure", @"锁具故障");
            }else if (eventType == KSHEventType_AppSynchronizeTheLockStatusEvent) {
                tips = NSLocalizedString(@"APP synchronization door lock status event", @"APP同步门锁状态事件");
            }else if (eventType == KSHEventType_LanguageSystemEvent) {
                tips = NSLocalizedString(@"Language system events", @"语言系统事件");
            }else if (eventType == KSHEventType_SystemLockStatusHasBeenReleased) {
                tips = NSLocalizedString(@"The system lock status has been released", @"系统锁定状态已解除");
            }else if (eventType == KSHEventType_TimeSynchronization) {
                tips = NSLocalizedString(@"Bluetooth lock to synchronize phone time", @"蓝牙锁同步手机时间");
            }else if (eventType == KSHEventType_RestoreFactorySettings) {
                tips = NSLocalizedString(@"Factory reset event", @"恢复出厂设置事件");
            }else if (eventType == KSHEventType_KeyWasNotTakenOut) {
                tips = NSLocalizedString(@"The key is not taken out", @"钥匙未取出事件");
            }else if (eventType == KSHEventType_OpenTheLockHead) {
                tips = NSLocalizedString(@"Open the lock cover event", @"打开锁盖头事件");
            }else {
                tips = [NSString stringWithFormat:NSLocalizedString(@"Other events, the event type is: %d", @"其它事件，事件类型为：%d"), eventType];
            }
        }
    }
    HXRecordCellModel *cellModel = [[HXRecordCellModel alloc] init];
    cellModel.title = tips;
    cellModel.obj = baseModel;
    cellModel.details = [HXResolutionFunc timeFromTimestamp:baseModel.timestamp];
    cellModel.cellHeight = stringSize(cellModel.title, CGSizeMake(QScreenWidth-30, 1000), 17).height + 50;
    [self.dataArray addObject:cellModel];
}

- (NSString *)deleteGroupKeyString:(HXPushEventDeleteKey *)model
{
    NSString *tips = @"";
    if (model.deleteMode == 3) {
        tips = [NSString stringWithFormat:NSLocalizedString(@"All keys of user %d are deleted by user %d", @"用户%d的所有钥匙被用户%d删除"),model.keyGroupId, model.operKeyGroupId];
    }else if (model.deleteMode == 1) {
        NSString *keyNames = [self keyNamesWithKeyTypes:model.keyType];
        tips = [NSString stringWithFormat:NSLocalizedString(@"All keys of type %@ in the Bluetooth lock are deleted by user %d", @"蓝牙锁中所有%@类型的钥匙被用户%d删除"), keyNames, model.operKeyGroupId];
    }else if (model.deleteMode == 0) {
        tips = [NSString stringWithFormat:NSLocalizedString(@"User %d deleted key %d", @"用户%d删除了钥匙%d"), model.operKeyGroupId, model.lockKeyId];
    }else if (model.deleteMode == 2) {
        tips = [NSString stringWithFormat:NSLocalizedString(@"User %d deleted the key with password/card number %@", @"用户%d删除了密码/卡号为%@的钥匙"), model.operKeyGroupId, model.key];
    }
    return tips;
}

- (NSString *)keyEnableString:(HXPushEventKeyEnable *)model
{
    NSString *tips = @"";
    
    if (model.operMode == 1) {
        tips = [NSString stringWithFormat:NSLocalizedString(@"The key %d is %@", @"钥匙%d被%@"), model.modifyLockKeyId, model.enable==1?NSLocalizedString(@"Enable", @"激活"):NSLocalizedString(@"Disable", @"禁用")];
    }else if (model.operMode == 2) {
        if ((model.modifyKeyTypes & KSHKeyType_Fingerprint) == KSHKeyType_Fingerprint) {
            if ((model.enable & KSHKeyType_Fingerprint) == KSHKeyType_Fingerprint) {
                tips = [tips stringByAppendingString:NSLocalizedString(@"Fingerprint is enabled ", @"指纹被激活 ")];
            }else {
                tips = [tips stringByAppendingString:NSLocalizedString(@"Fingerprint is disabled ", @"指纹被禁用 ")];
            }
        }
        if ((model.modifyKeyTypes & KSHKeyType_Password) == KSHKeyType_Password) {
            if ((model.enable & KSHKeyType_Password) == KSHKeyType_Password) {
                tips = [tips stringByAppendingString:NSLocalizedString(@"Password is enabled ", @"密码被激活 ")];
            }else {
                tips = [tips stringByAppendingString:NSLocalizedString(@"Password is disabled ", @"密码被禁用 ")];
            }
        }
        if ((model.modifyKeyTypes & KSHKeyType_Card) == KSHKeyType_Card) {
            if ((model.enable & KSHKeyType_Card) == KSHKeyType_Card) {
                tips = [tips stringByAppendingString:NSLocalizedString(@"Card is enabled", @"卡片被激活 ")];
            }else {
                tips = [tips stringByAppendingString:NSLocalizedString(@"Card is disabled", @"卡片被禁用 ")];
            }
        }
        if ((model.modifyKeyTypes & KSHKeyType_RemoteControl) == KSHKeyType_RemoteControl) {
            if ((model.enable & KSHKeyType_RemoteControl) == KSHKeyType_RemoteControl) {
                tips = [tips stringByAppendingString:NSLocalizedString(@"Remote control is enabled", @"遥控被激活 ")];
            }else {
                tips = [tips stringByAppendingString:NSLocalizedString(@"Remote control is disabled", @"遥控被禁用 ")];
            }
        }
        tips = [tips stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        tips = [NSString stringWithFormat:NSLocalizedString(@"%@ in Bluetooth lock", @"蓝牙锁中的%@"), tips];
        
    }else if (model.operMode == 3) {
        tips = [NSString stringWithFormat:NSLocalizedString(@"All keys of user %d are %@", @"用户%d的所有钥匙被%@"), model.modifyKeyGroupId, model.enable==1?NSLocalizedString(@"Enable", @"激活"):NSLocalizedString(@"Disable", @"禁用")];
    }
    return tips;
}

- (NSString *)modifyKeyTimeString:(HXPushEventModifyKeyTimeEvent *)model
{
    NSString *tips = @"";
    if (model.changeMode == 1) {
        tips = [NSString stringWithFormat:NSLocalizedString(@"User %d modified the validity period of the key %d", @"用户%d修改了钥匙%d的有效期"), model.operKeyGroupId, model.changeId];
    }else if (model.changeMode == 2) {
        tips = [NSString stringWithFormat:NSLocalizedString(@"User %d modified the validity period of user %d", @"用户%d修改了用户%d的有效期"), model.operKeyGroupId, model.changeId];
    }
    return tips;
}

- (NSString *)setSysPramString:(HXPushEventSystemParameters *)model
{
    NSMutableString *tips = [[NSMutableString alloc] initWithFormat:NSLocalizedString(@"The user has set the system parameters\n", @"用户设置了系统参数\n")];
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
        [tips appendString:NSLocalizedString(@"Door opening voice: enable\n", @"开门语音：打开\n")];
    }else if (model.volumeEnable == 2) {
        [tips appendString:NSLocalizedString(@"Door opening voice: disable\n", @"开门语音：关闭\n")];
    }
    if (model.systemVolume != 0) {
        [tips appendFormat:NSLocalizedString(@"System volume: %d", @"系统音量：%d"),model.systemVolume];
    }
    if (model.shackleAlarmEnable == 1) {
        [tips appendString:NSLocalizedString(@"Anti-pry alarm: enable\n", @"防撬报警：启动\n")];
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
