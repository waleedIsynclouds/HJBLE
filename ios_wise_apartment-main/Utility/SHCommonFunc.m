//
//  SHCommonFunc.m
//  DeviceConfigDemo
//
//  Created by JQ on 2018/8/11.
//  Copyright © 2018年 JQ. All rights reserved.
//

#import "SHCommonFunc.h"
#import <HXJBLESDK/JQBLEDefines.h>

@implementation SHCommonFunc

CGSize stringSize(NSString *text, CGSize limitSize, CGFloat fontSize)
{
    CGSize labelSize;
    if (text.length == 0) {
        return CGSizeZero;
    }
    labelSize =[text boundingRectWithSize:limitSize
                                  options:NSStringDrawingTruncatesLastVisibleLine
                | NSStringDrawingUsesLineFragmentOrigin
                | NSStringDrawingUsesFontLeading
                               attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:fontSize]}
                                  context:nil].size;
    return labelSize;
}

#pragma mark -弹框
#pragma mark ****************************************

void showAlertView(NSString *title, UIViewController *ctl)
{
    [SHCommonFunc showAlertViewWithTitle:title message:nil btnTitle:nil btnBlock:nil ctl:ctl];
}

void showDurationAlertView(NSString *title, UIViewController *ctl, CGFloat duration)
{
    [SHCommonFunc showAlertViewWithTitle:title message:nil btnTitle:nil btnBlock:nil ctl:ctl];
    [NSTimer scheduledTimerWithTimeInterval:duration repeats:NO block:^(NSTimer * _Nonnull timer) {
        dismissAlertView(ctl);
    }];
}

void showCompletionBlockAlertView(NSString *title, UIViewController *ctl, CGFloat duration, void(^completion)(void))
{
    [SHCommonFunc showAlertViewWithTitle:title message:nil btnTitle:nil btnBlock:nil ctl:ctl];
    [NSTimer scheduledTimerWithTimeInterval:duration repeats:NO block:^(NSTimer * _Nonnull timer) {
        dismissCompletionBlockAlertView(ctl, completion);
    }];
}

void dismissAlertView(UIViewController *ctl)
{
    if (ctl.presentedViewController) {
        [ctl.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

void dismissCompletionBlockAlertView(UIViewController *ctl, void(^completion)(void))
{
    if (ctl.presentedViewController) {
        [ctl.presentedViewController dismissViewControllerAnimated:YES completion:completion];
    }
}

+ (UIAlertController *)showAlertViewWithTitle:(NSString *)title
                                      message:(NSString *)message
                                     btnTitle:(NSString *)btnTitle
                                     btnBlock:(void(^)(void))block
                                          ctl:(UIViewController *)ctl
{
    UIAlertController *alert = [self showAlertViewWithTitle:title message:message btn1Title:btnTitle btn2Title:nil btn1Block:block btn2Block:nil animated:NO ctl:ctl];
    return alert;
}

+ (UIAlertController *)showAlertViewWithTitle:(NSString *)title
                                      message:(NSString *)message
                                    btn1Title:(NSString *)btn1Title
                                    btn2Title:(NSString *)btn2Title
                                    btn1Block:(void(^)(void))btn1Block
                                    btn2Block:(void(^)(void))btn2Block
                                     animated:(BOOL)animated
                                          ctl:(UIViewController *)ctl
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    if (btn1Title) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:btn1Title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (btn1Block) {
                NSLog(@"\n\nAlertAction：%@",btn1Title);
                btn1Block();
            }
        }];
        [alert addAction:action];
    }
    if (btn2Title) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:btn2Title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (btn2Block) {
                NSLog(@"\n\nAlertAction：%@",btn2Title);
                btn2Block();
            }
        }];
        [alert addAction:action];
    }
    if (ctl.presentedViewController) {
        [ctl.presentedViewController dismissViewControllerAnimated:NO completion:^{
            [ctl presentViewController:alert animated:animated completion:nil];
        }];
    }else {
        [ctl presentViewController:alert animated:animated completion:nil];
    }
    NSLog(@"\n\nshowAlertView\n%@\n%@",title?title:@"",message?message:@"");
    return alert;
}

+ (UIAlertController *)showTextFieldAlertViewWithTitle:(NSString *)title
                                               message:(NSString *)message
                                          confirmTitle:(NSString *)confirmTitle
                               textFieldConfigureBlock:(void(^)(UITextField *textField))textFieldConfigureBlock
                                          confirmBlock:(void(^)(UITextField *textField))confirmBlock
                                                   ctl:(UIViewController *)ctl
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.returnKeyType = UIReturnKeyDone;
        if (textFieldConfigureBlock) {
            textFieldConfigureBlock(textField);
        }
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"取消") style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:confirmTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (confirmBlock) {
            NSArray<UITextField *> *array =  alertController.textFields;
            UITextField *tf = [array firstObject];
            confirmBlock(tf);
        }
    }];
    [alertController addAction:confirmAction];
    [alertController addAction:cancelAction];
    if (ctl.presentedViewController) {
        [ctl.presentedViewController dismissViewControllerAnimated:NO completion:^{
            [ctl presentViewController:alertController animated:YES completion:nil];
        }];
    }else {
        [ctl presentViewController:alertController animated:YES completion:nil];
    }
    NSLog(@"\n\nshowAlertView\n%@\n%@",title?title:@"",message?message:@"");
    return alertController;
}

#pragma mark -导航栏
#pragma mark ****************************************

void pushViewCtl(UIViewController *currentCtl, UIViewController *pushCtl)
{
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", @"返回") style:UIBarButtonItemStylePlain target:nil action:nil];
    currentCtl.navigationItem.backBarButtonItem = barButtonItem;
    currentCtl.navigationController.navigationBar.tintColor = RGB(50, 50, 50);
    [currentCtl.navigationController pushViewController:pushCtl animated:YES];
}

void setNaviBarRightTitleButton(NSString *title, UIViewController *vc, SEL sel)
{
    setNaviBarRightTitleColorButton(title, vc, sel, QCommonStyleColor);
}

void setNaviBarRightTitleColorButton(NSString *title, UIViewController *vc, SEL sel, UIColor *tintColor)
{
    UIBarButtonItem *rightItem;
    if (title) {
        rightItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleDone target:vc action:sel];
        rightItem.tintColor = tintColor;
    }
    vc.navigationItem.rightBarButtonItem = rightItem;
}

void setNaviBarRightSystemButton(UIBarButtonSystemItem systemItem, UIViewController *vc, SEL sel)
{
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:systemItem target:vc action:sel];
    rightItem.tintColor = QCommonStyleColor;
    vc.navigationItem.rightBarButtonItem = rightItem;
}

NSString *com_getSystemLanguage(void)
{
    NSArray *appLanguages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    return [appLanguages objectAtIndex:0];
}

BOOL com_isChinese(void)
{
    NSString *appLanguage = com_getSystemLanguage();
    return [appLanguage hasPrefix:@"zh-Han"];
}

NSString *bleCommonTips(NSString *reason, NSInteger statusCode)
{
    BOOL isChinese = com_isChinese();
    if (isChinese) {
        return reason;
    }else {
        if (statusCode == KSHBLECommonStatus_DeviceHasBeenAdded) {
            reason = NSLocalizedString(@"Localizable_BLE_DeviceHasBeenAdded", @"您已拥有该设备的使用权限，不需要再重复添加");
            
        }else if (statusCode == 510001) {
            reason = NSLocalizedString(@"Localizable_BLE_510001", @"当前设备已被您添加过，不需要再重复添加");
            
        }else if (statusCode == 228) {
            reason = NSLocalizedString(@"Localizable_BLE_228", @"设备可能存在安全风险，如果您是门锁的所有者，请重置门锁后重新添加设备");
            
        }else if (statusCode == KSHStatusCode_DNAKeyWrong) {
            reason = NSLocalizedString(@"Localizable_BLE_800007", @"设备已被重置过，如果您是门锁所有者，请重新添加设备");

        }else if (statusCode == KSHStatusCode_invalidParam) {
            reason = NSLocalizedString(@"Localizable_BLE_invalidParam", @"参数无效");
            
        }else if (statusCode == KSHStatusCode_BluetoothStateUnavailable) {
            reason = NSLocalizedString(@"Localizable_BLE_Unavailable", @"蓝牙不可用，请先打开手机蓝牙");
            
        }else if (statusCode == KSHBLECommonStatus_AuthError) {
            reason = NSLocalizedString(@"Localizable_BLE_AuthError", @"鉴权失败");
            
        }else if (statusCode == KSHBLECommonStatus_Busy) {
            reason = NSLocalizedString(@"Localizable_BLE_Busy", @"命令发送过于频繁，请稍后再试");
            
        }else if (statusCode == KSHBLECommonStatus_TypeError) {
            reason = NSLocalizedString(@"Localizable_BLE_TypeError", @"数据加密类型错误，可能存在安全风险。如果您是门锁的所有者，请重置门锁后重新添加设备");
            
        }else if (statusCode == KSHBLECommonStatus_SessionIdError) {
            reason = NSLocalizedString(@"Localizable_BLE_SessionIdError", @"SessionId错误");
            
        }else if (statusCode == KSHBLECommonStatus_NotPairing) {
            reason = NSLocalizedString(@"Localizable_BLE_NotPairing", @"如果您正在添加设备，请先配置设备使其进入添加状态。设备还未被添加，添加成功后才能继续其它操作");
            
        }else if (statusCode == KSHBLECommonStatus_CmdNotAllowed) {
            reason = NSLocalizedString(@"Localizable_BLE_CmdNotAllowed", @"命令不允许");
            
        }else if (statusCode == KSHBLECommonStatus_PasswordError) {
            reason = NSLocalizedString(@"Localizable_BLE_PasswordError", @"密码错误");
            
        }else if (statusCode == KSHBLECommonStatus_NoAppUnlockFunction) {
            reason = NSLocalizedString(@"Localizable_BLE_NoAppUnlockFunction", @"远程开锁未开启(锁本地拨码开关未打上)");
            
        }else if (statusCode == KSHBLECommonStatus_ParameterError) {
            reason = NSLocalizedString(@"Localizable_BLE_ParameterError", @"参数错误");
            
        }else if (statusCode == KSHBLECommonStatus_NeedAddAdminFirst) {
            reason = NSLocalizedString(@"Localizable_BLE_NeedAddAdminFirst", @"禁止此项操作,请先添加管理员");
            
        }else if (statusCode == KSHBLECommonStatus_DoorlockNotSupported) {
            reason = NSLocalizedString(@"Localizable_BLE_DoorlockNotSupported", @"门锁不支持此命令或操作");
            
        }else if (statusCode == KSHBLECommonStatus_KeysAlreadyExist) {
            reason = NSLocalizedString(@"Localizable_BLE_KeysAlreadyExist", @"重复添加(卡片/密码等)");
            
        }else if (statusCode == KSHBLECommonStatus_ErrorNo) {
            reason = NSLocalizedString(@"Localizable_BLE_ErrorNo", @"编号错误");
            
        }else if (statusCode == KSHBLECommonStatus_AntiLockNotAllowed) {
            reason = NSLocalizedString(@"Localizable_BLE_AntiLockNotAllowed", @"不允许开反锁");
            
        }else if (statusCode == KSHBLECommonStatus_SystemLocked) {
            reason = NSLocalizedString(@"Localizable_BLE_SystemLocked", @"系统已锁定");
            
        }else if (statusCode == KSHBLECommonStatus_AdmCannotBeDeleted) {
            reason = NSLocalizedString(@"Localizable_BLE_AdmCannotBeDeleted", @"禁止删除管理员");
            
        }else if (statusCode == KSHBLECommonStatus_LockedMemorySpaceFull) {
            reason = NSLocalizedString(@"Localizable_BLE_LockedMemorySpaceFull", @"门锁存储数量已满,不允许再设置");
            
        }else if (statusCode == KSHBLECommonStatus_WaitForOtherPackets) {
            reason = NSLocalizedString(@"Localizable_BLE_WaitForOtherPackets", @"还有后续数据包");
            
        }else if (statusCode == KSHBLECommonStatus_DoorIsLockedAndAntilockNotAllowed) {
            reason = NSLocalizedString(@"Localizable_BLE_DoorIsLockedAndAntilockNotAllowed", @"门已反锁,不允许开反锁");
            
        }else if (statusCode == KSHBLECommonStatus_NeedToAddDeviceFirst) {
            reason = NSLocalizedString(@"Localizable_BLE_NeedToAddDeviceFirst", @"请先添加设备");
            
        }else if (statusCode == KSHStatusCode_BluetoothConnectionFailed) {
            reason = NSLocalizedString(@"Localizable_BLE_ConnectionFailed", @"连接蓝牙设备失败");
            
        }else if (statusCode == KSHStatusCode_BluetoothNotFound) {
            reason = NSLocalizedString(@"Localizable_BLE_NotFound", @"暂未扫描到蓝牙设备，请确认设备已打开并在有效距离内操作");
            
        }else if (statusCode == KSHStatusCode_DidDisconnectPeripheral) {
            reason = NSLocalizedString(@"Localizable_BLE_DidDisconnectPeripheral", @"手机与外设断开连接");
            
        }else if (statusCode == KSHStatusCode_ServiceNotExist) {
            reason = NSLocalizedString(@"Localizable_BLE_ServiceNotExist", @"蓝牙外设中不存在指定服务");
            
        }else if (statusCode == KSHStatusCode_ServiceNotFound) {
            reason = NSLocalizedString(@"Localizable_BLE_ServiceNotFound", @"蓝牙外设中还没有发现指定服务，请重试");
            
        }else if (statusCode == KSHStatusCode_CharacteristicNotFound||
                  statusCode == KSHStatusCode_CharacteristicNotExist) {
            reason = NSLocalizedString(@"Localizable_BLE_CharacteristicNotFound", @"蓝牙外设中还没有发现指定特征，请重试");
            
        }else if (statusCode == KSHStatusCode_Failed) {
            reason = NSLocalizedString(@"Localizable_Failed", @"操作失败");
            
        }else if (statusCode == KSHStatusCode_Timeout) {
            reason = NSLocalizedString(@"Localizable_RequestTimedOut", @"请求超时");
            
        }if (statusCode == KSHStatusCode_Success) {
            reason = NSLocalizedString(@"Localizable_Successfully", @"成功");
            
        }else if (statusCode == KSHBLECommonStatus_Forbidden) {
            reason = NSLocalizedString(@"Localizable_NoPermission", @"暂无权限操作");
            
        }else if (statusCode == KSHBLECommonStatus_ExitAddKey) {
            reason = NSLocalizedString(@"Localizable_BLEExitAddKey", @"设备已退出添加模式");
            
        }else if (statusCode == KSHStatusCode_BluetoothStateDenied) {
            reason = NSLocalizedString(@"pleaseAllowAppAccessToYourBLE", @"您未授权App访问您的蓝牙，请在iPhone的'设置-隐私-蓝牙'选项中，允许App访问您的蓝牙。");
        }else if (statusCode == KSHBLECommonStatus_NBBusy) {
            reason = NSLocalizedString(@"The NB-IoT module is busy, please try again later!", @"NB-IoT模组正忙，请稍后再试！");
        }
        return reason;
    }
}

@end
