//
//  HXAddKeyVC.m
//  HXJBLESDKDemo
//
//  Created by JQ on 2019/5/29.
//  Copyright © 2019 JQ. All rights reserved.
//

#import "HXAddKeyVC.h"

#import <HXJBLESDK/HXBluetoothLockHelper.h>
#import "HXCoreDataStackHelper.h"
#import "HXAddBigDataKeyHelper.h"
#import "HXTitleCellModel.h"

typedef NS_ENUM(NSInteger, kHXAddKeyVCCellType) {
    kHXAddKeyVCCellType_fingerprint = 1,
    kHXAddKeyVCCellType_password,
    kHXAddKeyVCCellType_card,
    kHXAddKeyVCCellType_remoteControl,
    kHXAddKeyVCCellType_fingerprintData,
    kHXAddKeyVCCellType_faceData,
};

@interface HXAddKeyVC ()

@property (nonatomic, strong) HXAddBigDataKeyHelper *addBigDataKeyHelper;

@property (nonatomic, strong) UIAlertController *alertCtl;

@end

@implementation HXAddKeyVC

- (void)dealloc {
    [_addBigDataKeyHelper cancel];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"Add key", @"添加钥匙");
    [self loadData];
}

- (void)loadData
{
    kHXLockFunctionType lockFunctionType = self.bleDevice.lockFunctionType;
    if ((lockFunctionType & kHXLockFunctionType_supportFingerprint) == kHXLockFunctionType_supportFingerprint) {
        //支持指纹
        HXTitleCellModel *fingerprintModel = [[HXTitleCellModel alloc] initWithTitle:NSLocalizedString(@"Add fingerprint", @"添加指纹") type:kHXAddKeyVCCellType_fingerprint];
        [self.dataArray addObject:fingerprintModel];
    }
    
    if ((lockFunctionType & kHXLockFunctionType_supportPassword) == kHXLockFunctionType_supportPassword) {
        //支持密码
        HXTitleCellModel *passwordModel = [[HXTitleCellModel alloc] initWithTitle:NSLocalizedString(@"Add password", @"添加密码") type:kHXAddKeyVCCellType_password];
        [self.dataArray addObject:passwordModel];
    }
    
    if ((lockFunctionType & kHXLockFunctionType_supportCard) == kHXLockFunctionType_supportCard) {
        //支持卡片
        HXTitleCellModel *cardModel = [[HXTitleCellModel alloc] initWithTitle:NSLocalizedString(@"Add card", @"添加卡片") type:kHXAddKeyVCCellType_card];
        [self.dataArray addObject:cardModel];
    }
    
    if ((lockFunctionType & kHXLockFunctionType_supportRemoteControl) == kHXLockFunctionType_supportRemoteControl) {
        //支持遥控
        HXTitleCellModel *remoteControlModel = [[HXTitleCellModel alloc] initWithTitle:NSLocalizedString(@"Add remote control", @"添加遥控") type:kHXAddKeyVCCellType_remoteControl];
        [self.dataArray addObject:remoteControlModel];
    }
    
    if ((lockFunctionType & kHXLockFunctionType_supportFingerprint) == kHXLockFunctionType_supportFingerprint) {
        //支持指纹
        HXTitleCellModel *fingerprintModel = [[HXTitleCellModel alloc] initWithTitle:NSLocalizedString(@"Localizable_AddFingerprintData", @"添加指纹数据") type:kHXAddKeyVCCellType_fingerprintData];
        [self.dataArray addObject:fingerprintModel];
    }
    
    if ((lockFunctionType & kHXLockFunctionType_supportFace) == kHXLockFunctionType_supportFace) {
        //支持人脸
        HXTitleCellModel *faceModel = [[HXTitleCellModel alloc] initWithTitle:NSLocalizedString(@"Localizable_AddFaceData", @"添加人脸数据") type:kHXAddKeyVCCellType_faceData];
        [self.dataArray addObject:faceModel];
    }
    [self.tableView reloadData];
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
    return 66;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"addKeyVCCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    HXTitleCellModel *cellModel = self.dataArray[indexPath.row];
    cell.textLabel.text = cellModel.title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    HXTitleCellModel *cellModel = self.dataArray[indexPath.row];
    kHXAddKeyVCCellType type = cellModel.type;
    if (type == kHXAddKeyVCCellType_password) {
        [self addPasswordKey];
        
    }else {
        NSString *title = nil;
        NSString *message = nil;
        KSHKeyType keyType = 1;
        if (type == kHXAddKeyVCCellType_fingerprint) {
            title = NSLocalizedString(@"Add fingerprint", @"添加指纹");
            message = NSLocalizedString(@"Need to press multiple times to enter the fingerprint", @"需要按压多次录入指纹");
            keyType = KSHKeyType_Fingerprint;
            
        }else if (type == kHXAddKeyVCCellType_card) {
            title = NSLocalizedString(@"Add card", @"添加卡片");
            message = NSLocalizedString(@"After hearing the bluetooth lock indicator tone, place the card on the bluetooth lock panel", @"听到蓝牙锁指示音后，将卡片放置到蓝牙锁面板上");
            keyType = KSHKeyType_Card;
            
        }else if (type == kHXAddKeyVCCellType_remoteControl) {
            title = NSLocalizedString(@"Add remote control", @"添加遥控");
            keyType = KSHKeyType_RemoteControl;
            
        }else if (type == kHXAddKeyVCCellType_fingerprintData) {
            [self onAddFingerPrintCell];
            return;
        }else if (type == kHXAddKeyVCCellType_faceData) {
            [self onAddFaceCell];
            return;
        }
        
        if (title) {
            [self addOtherKeyWithTitle:title message:message keyType:keyType];
        }
    }
}

- (void)addPasswordKey
{
    [SHCommonFunc showTextFieldAlertViewWithTitle:NSLocalizedString(@"Add password", @"添加密码") message:NSLocalizedString(@"Password length is 6-12 digits", @"密码长度为6～12位的数字") confirmTitle:NSLocalizedString(@"Start adding", @"开始添加") textFieldConfigureBlock:^(UITextField *textField) {
        textField.keyboardType = UIKeyboardTypeNumberPad;
    } confirmBlock:^(UITextField *textField) {
        if (textField.text.length < 6 || textField.text.length > 12) {
            showDurationAlertView(NSLocalizedString(@"Password length is 6-12 digits", @"密码长度要求6～12位！"), self, 1.5);
            return;
        }
        __weak typeof(self)wself = self;
        HXBLEAddPasswordKeyParams *params = [[HXBLEAddPasswordKeyParams alloc] init];
        params.key = textField.text;
        params.lockMac = self.bleDevice.lockMac;
        params.keyGroupId = 901;
        params.vaildNumber = 255;
        [self setRandomTimeParam:params];
        showAlertView(NSLocalizedString(@"Ready to add a password, please wait...", @"准备添加密码，请稍后..."), self);
        [HXBluetoothLockHelper addKey:params completionBlock:^(KSHStatusCode statusCode, NSString *reason, HXKeyModel *keyObj, int authTotal, int authCount) {
            if (statusCode == KSHStatusCode_Success) {
                //添加钥匙只需验证一次
                [HXCoreDataStackHelper saveKey:keyObj];
                NSString *tips = [NSString stringWithFormat:NSLocalizedString(@"Password: %@, please keep the password properly by yourself", @"密码：%@，请自行妥善保管该密码"),params.key];
                [SHCommonFunc showAlertViewWithTitle:NSLocalizedString(@"Add password successfully", @"添加密码成功") message:tips btnTitle:NSLocalizedString(@"Got it", @"知道了") btnBlock:nil ctl:wself];
            }else {
                NSString *tips = bleCommonTips(reason, statusCode);
                showDurationAlertView(tips, wself, 2);
            }
        }];
        
    } ctl:self];
}

- (void)addOtherKeyWithTitle:(NSString *)title message:(NSString *)message keyType:(KSHKeyType)keyType
{
    [SHCommonFunc showAlertViewWithTitle:title message:message btn1Title:NSLocalizedString(@"Cancel", @"取消") btn2Title:NSLocalizedString(@"Start adding", @"开始添加") btn1Block:nil btn2Block:^{
        __weak typeof(self)wself = self;
        HXBLEAddOtherKeyParams *params = [[HXBLEAddOtherKeyParams alloc] init];
        params.keyType = keyType;
        params.lockMac = self.bleDevice.lockMac;
        params.keyGroupId = 901;
        params.vaildNumber = 255;
        [self setRandomTimeParam:params];
        showAlertView(NSLocalizedString(@"Ready to add, please wait...", @"准备添加，请稍后..."), self);
        [HXBluetoothLockHelper addKey:params completionBlock:^(KSHStatusCode statusCode, NSString *reason, HXKeyModel *keyObj, int authTotal, int authCount) {
            if (statusCode == KSHStatusCode_Success) {
                if (authTotal == authCount) {
                    [HXCoreDataStackHelper saveKey:keyObj];
                    NSString *tips = [NSString stringWithFormat:NSLocalizedString(@"%@ success", @"%@成功"),title];
                    showDurationAlertView(tips, wself, 1.5);
                }else {
                    NSString *tips;
                    if (authTotal == 255) {
                        tips = [NSString stringWithFormat:NSLocalizedString(@"Please enter (%d)", @"请录入（%d）"), authCount];
                    }else {
                        tips = [NSString stringWithFormat:NSLocalizedString(@"Please enter (%d/%d)", @"请录入（%d/%d）"), authCount, authTotal];
                    }
                    [SHCommonFunc showAlertViewWithTitle:tips message:nil btnTitle:NSLocalizedString(@"Exit add mode", @"退出添加模式") btnBlock:^{
                        [HXBluetoothLockHelper exitCmdWithLockMac:wself.bleDevice.lockMac completionBlock:nil];
                    } ctl:wself];
                }
            }else {
                NSString *tips = bleCommonTips(reason, statusCode);
                showDurationAlertView(tips, wself, 2);
            }
        }];
    } animated:YES ctl:self];
}

- (void)onAddFingerPrintCell {
    NSString *fingerPrintBase64Str = @"EgYAAFAgiVBCTVQAA/8BAQAVBQwDAAAH+AAAAgEA/wAAAAAAAAAAAAAAAQBDAAACFH8uggIPoVKBSCYzjBhCjyZLTzFHjDEjhA89cEA2uUsxeTMRZz4RgQ4NqUYNvQoijAgwTwgYTkBIb0NPbkFCrz0NZB4diDoQpUQInTgQhDkOfZIGAUBCAD29ooIBt4IcmOwV4fTk5eXT08bEs6Ojk4SEc2ZFRTMjJCMTE8GCAY0MAA4ADgAAAAA+iDlvRXJGdFJiY2JqhQAAAACHipaHlHsAAClcMW81bDx1RHpVeF2KY5MAAAAAAACVipmLAAAAAC6fLH42eD2DRoxWh1pHYkd8gZGCmo+figAAAAAllymMMYU1lD+MS4xWgWdmfXWRgZuBpYUAAAAAIJIihCeKMZ04jEGGU4JnfX10knWoealyAAAAABqHGX0ZeC2BM4Q0elWDZm1/bZNyqnGvewAAFHkWghuCHXwjhSl5MWxIYF5kfV+SXqt5sHgAABSCFoIWfhWCFX8lhTBmO15NYHtbmF27Ub2LAAAPdw6ABncOgxBrImIrYixlPl1kRqlxwoHDgwAAC34RdgF1B4YOahRlG1wibDZYW0m1c8140XsAAAAA9oj5ZQRnBXQPaRVlG3gxaVlNynDUgdh6AAAAAAGB92b+Zv91Em0UZyZLLWxFV+Nk3oDjggAAAXT/ef1g+WT5dC5nI2AvZiFm5j/jW+x77H0AAAAA/Xb2Xfhi+nQ6WzJoKkseXSFc8mL9dfp3wwYBqACoAFEAAAACAEMAAAHofy6CAeOhMYEnDiyEDk6LKTa4HT65FQSiOSW5AjuLIxR+JBGhCwOmRh9bQwd9BwWEkgYBQB4ASL2iggGsghGY7BXh4+XDxcTDxbOzRCMTFMGCAY0MAA4ADkxuVUVqnn45sEiDnXhBj4CXfp1/pYIAAAAAAABQbWCCZnxsem9shXuPf5SDmn6cgaKCAAAAAAAAUXRcfGGIb4leQAAAj4mUiJ+Bon6mgppnAAAAABQ5VZNdjGuWdpl1gpaVmYWgiaSHqoKqgwAAAABCk06QWY5dUXFlh4SWiZ2RopCkkamKp4YAAAAAPJREjU+AYXVvdYd2mn6mdq13nWyungAAAAAAADeLO4NEhmN/cnSIcp9wq3q1dL2CuY27jQAAAAAtezB0SVxdaXJpg2Smd7B4un+/eMN7wXjAfAAAI4Qzcj1jT2NrYIdeoVy5h8B7y3/HcstrwVMAACJILWYwYz9gX0+LWb51vonEisyGzG/KcNRcAAAZXyBfJmY1YVpKrnHBe8180YjTitZ522mXOgAAEmcWYRxvMGlHWadd0H/UdNNt2orch9xx2HIAABNtF2cfhy5vQlmUW9h323rhbOZ/3YPffOFeAAAqaxxlKVcrcDti4FnleeV46nvpdeh84n4AAAAAwwYBqACoAFIAAAADAEMAAAHYfy6CAdOhI4EhE0+LBz2LEy6EDgaCPyV5KU6iLji4JEC4HwRdKROkKBSCooIBqoIPmOwV4fXk49TDxMTFEhITwYIBjQwADgAOSXNPbllQbZ9zo3qbhJaGiZCFlYOghgAAAAAAAEpyTmlmaWWAb3ttb4mBkIeUg5t8oYGniQAAAABJdlB1YG1lg2+EcnaGgpKElYCdgqGBpoIAAAAAQX9Ri1uTYZVumXiZipuVlJmHoYyjgaqDn3EAAEGNRplUjVyNX1F3TI6Jl42ekqGNqIyrh6iEAAAzlD2QSY5UiWNweHWOfZuCpH+ng6KHp5UAAAAANaI3kz+FSYhlgnl1j3Gld6l4tXa8h7WUuZUAACqHL4Ezdk1YYWx6a41uqHaxeb16vnnAgL6BAAAghSaBM3BDYlhkemCHXapvuYO/gMZ8x3PIbMpyFH4kiS9nNmFHYWlbmFu/YL6PxX7OfsxszGzRWRFrHWElYCpoOmFjRq12wYDIgM6Q0YnRcrA9AAAKahFlF2EfcTVfWk22a9F503TUitmI3H/fcdVoBHcRbRdnGYAxa0dXnF7Ygdl44mrfhtuG3W7aaP96FHsYZSVTLG5BXJlg3X/keup86Hbnfud563fDBgGoAKgAVo1fUXdMjomXjZ6SoY2ojKuHqIQAADOUPZBJjlSJY3B4dY59m4Kkf6eDooenlQAAAAA1ojeTP4VJiGWCeXWPcaV3qXi1dryHtZS5lQAAKocvgTN2TVhhbHprjW6odrF5vXq+ecCAvoEAACCFJoEzcENiWGR6YIddqm+5g7+AxnzHc8hsynIUfiSJL2c2YUdhaVuYW79gvo/Ffs5+zGzMbNFZEWsdYSVgKmg6YWNGrXbBgMiAzpDRidFysD0AAApqEWUXYR9xNV9aTbZr0XnTdNSK2Yjcf99x1WgEdxFtF2cZgDFrR1ecXtiB2Xjiat+G24bdbtpo/3oUexhlJVMsbkFcmWDdf+R66nzodud+53nrd8MGAagAqABWU4owAAAAAAAAAHhuACASBgAAUAAAAAAAAAABAAAAAAAAAD1jAAB4bgAguUsAAB2CIX30gQEAAAAAAP////8A4QAAAAAAADJNgAABAAAAZAAAZAAKFAAABQHwMk0AAAAAAAAAAAAAAAAAAAAAWqVapfnwMk358DJN+fAyTfnwMk358DJN+fAyTfnwMk358DJN+fAyTfnwMk358DJN+fAyTfnwMk358DJN+fAyTfnwMk358DJN+fAyTfnwMk358DJN+fAyTfnwMk358DJN+fA=";
    [self startAddBidDataKey:fingerPrintBase64Str keyType:KSHKeyType_Fingerprint];
}

- (void)onAddFaceCell {
//    NSString *faceBase64Str = @"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";
    NSString *faceBase64Str = @"RUZJdjIAAADJd0bM8yZr+saBWD3ADU9L062sffyP1TvLT+BLhMDL+x5FLj1ice/LEBw/e3uCcLzRfX9LQ2vfe2t6NT3Y0/nLY0fZe9L3ND3HNyPLmcjke1EKzzxxE0jKRHeM+7noHDyRSgTLHwz9e8iVqr3u1gLLz/bIesuH1r0UHw3NE2pqe225P7xtYrLLFA93+1HQv72QsE1LIhfp+phkSr2HadNL8FIq+xswCTxNxpnLlxlWevnz/D0EkwlLkzD7e2mrhTwdwvfLOsN9+wqwXb2Mc9zL33zn++yS+b3y033IE2jHexpvcz0jWLRKSs7g/QOwpr3D2ZfKRC3x+2YeaLoRWuXLFg/de4eavz32/n5LyG9g+z3kMD6QdUjIFOsSe3hFx7ut8A5L4PM6eijpkbsRCK1LZTTX+8Cjtj1mB+RLfC8HeyjuQjxVOVJL+Kbp+9oAdLy4ZsvL1YXjevAst720BjzLauK/egUWnzxmD3TLs7I1fVEDBLyeAW/K5iV5+4Hk3rzOfvJKJdIXe5pak70CrZ1K0knReq7sKD7cw0RLjAnue82h0j1Er6hK7sHf+oANjb35/LvN05rB+40fSrvQXMtLhsTe+lw4x7t+f53LwGf0+qyiuL3fV1BLchQf+jbEQT1mZcbKkubee7zTtz36LxdLj7G/fS0kNz6HpJxLoizse8cn+zuLXvLLTZCR/Vgm0z2WyYXLSTT0+7gCi7wPUe7KMnyK+xVNtTxh4UHNhfnZewakeTtT6AXKZuTK+2PokL3MFFvLISfY+zj2xjszoGJKhio5+3Msxzy8XtXKWQzPe9yO1D2A4sZKBcFk+u5htL0CHc1LE8et+voLJzwnFS1LdzZWe03qpTxnRhxL3HKv+jQ6E73SKsJLmWeQ/TrwT7xtPpvK9P6qesOYELwZR+tLgrh5eyODfzyb3sfLHzPzfZcNy73t3EJLJjyn+vaMeb3yxNfLOM2Nex+Ypz27FtzLN5rD/D/gSr128vpKKQ2++r2MwLpmCppKC+BG+09at7xSzoJLh37wenmfy720i1nIUA2XevDDq72ItcbL8Pq/+hRjPz27/jdLPz43e/8KA71i1iFLjqTb+9A9ELpZeBLLzCll+1yvQL2TQ4FLxp3qe1cIvj2XwPpLSQTX+7iRSb0HD9BL/jGKejG8cz0TF2nLqA+teo6gjr0C/O5LLxT3eiiKhzzrgARItxjX/UfrdLsr5xbLYCxv+xzP0b1cox9KRy16e5CISr1j5bVKyaPy+9lc+b2/1oxKSAPMe+UprzygdIFLibWF+gLYXr0VbA5L/1CMe2d1Tb1bG9PKpxLJ+1Dx5Dz7gP7LUYIr/clGVL1rzZ/KUd81ezTuTj1j6h/M";
    // 注意：faceBase64Str 需要经过服务器进一步处理后获取，避免图片不满足门锁识别的要求
    [self startAddBidDataKey:faceBase64Str keyType:KSHKeyType_Face];
}

- (void)startAddBidDataKey:(NSString *)keyBase64Str keyType:(KSHKeyType)keyType {
    if (!_addBigDataKeyHelper) {
        _addBigDataKeyHelper = [[HXAddBigDataKeyHelper alloc] init];
    }
    __weak typeof(self)weakSelf = self;
    if (!weakSelf.alertCtl) {
        weakSelf.alertCtl = [SHCommonFunc showAlertViewWithTitle:NSLocalizedString(@"Localizable_preBleSendFaceKey", @"准备蓝牙下发人脸/指纹数据...") message:nil btnTitle:nil btnBlock:nil ctl:weakSelf];
    }
    int keyGroup = 901;
    SHBLEKeyValidTimeParam *param = [self getRandomTimeParam];
    
    [_addBigDataKeyHelper startWithBigDataBase64Str:keyBase64Str lockMac:self.bleDevice.lockMac keyGroupId:keyGroup keyType:keyType timeParam:param progressBlock:^(NSInteger statusCode, NSString * _Nullable reason, KSHBLESendBigKeyDataPhase phase, CGFloat progress, HXKeyModel * _Nullable keyObj) {
        
        [NSObject cancelPreviousPerformRequestsWithTarget:weakSelf selector:@selector(dismissAlertCtl) object:nil];
        NSLog(@"status = %ld, reason = %@, phase = %ld, progress = %f", statusCode, reason, phase, progress);
        int time = 1.5;
        if (phase == KSHBLESendBigKeyDataPhase_end) {
            [HXCoreDataStackHelper saveKey:keyObj];
            weakSelf.alertCtl.title = NSLocalizedString(@"Successfully", @"成功");
            
        } else {
            if (statusCode == KSHStatusCode_Success) {
                time = 20;
            }
            NSString *progressStr = [NSString stringWithFormat:@"%d%%",(int)(progress*100)];
            NSString *tips = [NSString stringWithFormat:@"%@\n%@",reason, progressStr];
            weakSelf.alertCtl.title = tips;
        }
        [weakSelf performSelector:@selector(dismissAlertCtl) withObject:nil afterDelay:time];
    }];
}

// 请根据实际情况设置人脸钥匙的有效期 (特别注意：keyGroupId为900的用户只支持添加永久钥匙)
- (SHBLEKeyValidTimeParam *)getRandomTimeParam
{
    SHBLEKeyValidTimeParam *param = [[SHBLEKeyValidTimeParam alloc] init];
    int authMode = arc4random()%2==1?1:2;
    param.authMode = authMode;
    if (authMode == 1) {
        //有效期授权
        if (arc4random()%2==0) {
            //永久有效
            param.validStartTime = 0;
            param.validEndTime = 0xFFFFFFFF;
        }else {
            //30天有效
            param.validStartTime = [[NSDate date] timeIntervalSince1970];
            param.validEndTime = param.validStartTime+(30*24*60*60);
        }
        
    }else if (authMode == 2){
        //周期重复时间段授权
        param.weeks = kSHWeek_monday|kSHWeek_tuesday|kSHWeek_wednesday|kSHWeek_thursday|kSHWeek_friday|kSHWeek_saturday|kSHWeek_sunday;
        //09:00 ~ 21:00
        param.dayStartTimes = 9*60;
        param.dayEndTimes = 21*60;
        
        //1天有效
        param.validStartTime = [[NSDate date] timeIntervalSince1970];
        param.validEndTime = param.validStartTime+(24*60*60);
    }
    param.vaildNumber = 0xFF;
    param.modifyTimestamp = [[NSDate date] timeIntervalSince1970];
    return param;
}

- (void)dismissAlertCtl {
    if (self.alertCtl) {
        [self.alertCtl dismissViewControllerAnimated:NO completion:nil];
        self.alertCtl = nil;
    }
}

static BOOL controlVar = NO;

- (void)setRandomTimeParam:(HXBLEAddKeyBaseParams *)param
{
    int authMode = controlVar?1:2;
    param.authMode = authMode;
    if (arc4random()%2==0) {
        //永久有效
        param.validStartTime = 0;
        param.validEndTime = 0xFFFFFFFF;
    }else {
        //30天有效
        param.validStartTime = [[NSDate date] timeIntervalSince1970];
        param.validEndTime = param.validStartTime+(30*24*60*60);
    }
    if (authMode == 1) {
        //有效期授权
    }else if (authMode == 2){
        //周期重复时间段授权
        param.week = kSHWeek_monday|kSHWeek_tuesday|kSHWeek_wednesday|kSHWeek_thursday|kSHWeek_friday|kSHWeek_saturday|kSHWeek_sunday;
        //09:00 ~ 21:00
        param.dayStartTimes = 9*60;
        param.dayEndTimes = 21*60;
    }
    controlVar = !controlVar;
}

@end
