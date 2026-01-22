//
//  HXKeyListVC.m
//  HXJBLESDKDemo
//
//  Created by JQ on 2019/5/29.
//  Copyright © 2019 JQ. All rights reserved.
//

#import "HXKeyListVC.h"
#import "HXAddKeyVC.h"
#import "HXKeyDetaisVC.h"

#import <HXJBLESDK/HXBluetoothLockHelper.h>
#import "HXCoreDataStackHelper.h"
#import "HXResolutionFunc.h"

#import "HXAddView.h"

@interface HXKeyListVC ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) HXAddView *addView;

@property (nonatomic, strong) HXBLEDevice *bleDevice;

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) NSMutableArray *tempKeyArray;

@end

@implementation HXKeyListVC

- (instancetype)initWithBLEDevice:(HXBLEDevice *)bleDevice
{
    self = [super init];
    if (self) {
        self.bleDevice = bleDevice;
        _dataArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubviews];
}

- (void)setupSubviews
{
    self.navigationItem.title = NSLocalizedString(@"Key list", @"钥匙列表");
    setNaviBarRightSystemButton(UIBarButtonSystemItemRefresh, self, @selector(refresh));
    
    self.view.backgroundColor = [UIColor whiteColor];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, QNavigationBarHeight, QScreenWidth, QScreenHeight-QNavigationBarHeight-safeArea-80) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = RGB(239, 239, 245);
    [self.view addSubview:_tableView];
    
    [self showAddView];
}

- (void)showAddView
{
    _addView = [[HXAddView alloc] initWithFrame:CGRectMake(0, QScreenHeight-80-safeArea, CGRectGetWidth(self.view.frame), 80) title:NSLocalizedString(@"Add key", @"添加钥匙")];
    [_addView btnAddTarget:self action:@selector(addKey)];
    [self.view addSubview:_addView];
}

- (void)loadData
{
    NSArray<HXKeyModel *> *keyArr = [HXCoreDataStackHelper keyListWithLockMac:self.bleDevice.lockMac];
    [self.dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:keyArr];
    [self.dataArray sortUsingComparator:^NSComparisonResult(HXKeyModel *obj1, HXKeyModel *obj2) {
        return obj1.lockKeyId < obj2.lockKeyId;
    }];
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
    static NSString *reuseIdentifier = @"keyListVCCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.font = [UIFont systemFontOfSize:17];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
        cell.detailTextLabel.textColor = RGB(179, 179, 179);
    }
    HXKeyModel *keyModel = self.dataArray[indexPath.row];
    NSString *cardOrPassword = @"";
    if (keyModel.keyType == KSHKeyType_Card ||
        keyModel.keyType == KSHKeyType_Password) {
        if (keyModel.key.length > 0) {
            cardOrPassword = [NSString stringWithFormat:@"- %@",keyModel.key];
        }
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (ID:%03d) %@",[HXResolutionFunc keyNameWithType:keyModel.keyType],keyModel.lockKeyId, cardOrPassword];
    cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"User %d", @"用户%d"),keyModel.keyGroupId];
    cell.imageView.image = [UIImage imageNamed:@"key"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    HXKeyModel *keyModel = self.dataArray[indexPath.row];
    HXKeyDetaisVC *vc = [[HXKeyDetaisVC alloc] initWithBLEDevice:self.bleDevice bleKey:keyModel];
    pushViewCtl(self, vc);
}

#pragma mark -添加钥匙
#pragma mark *********************************
- (void)addKey
{
    HXAddKeyVC *vc = [[HXAddKeyVC alloc] initWithBLEDevice:self.bleDevice];
    pushViewCtl(self, vc);
}

#pragma mark -同步蓝牙锁钥匙列表
#pragma mark *********************************
- (void)refresh
{
    [SHCommonFunc showAlertViewWithTitle:NSLocalizedString(@"Sync key list", @"向蓝牙锁同步钥匙列表") message:nil btn1Title:NSLocalizedString(@"Cancel", @"取消") btn2Title:NSLocalizedString(@"Confirm", @"确定") btn1Block:nil btn2Block:^{
        __weak typeof(self)wself = self;
        showAlertView(NSLocalizedString(@"Start syncing...", @"开始同步..."), self);
        if (!self.tempKeyArray) {
            self.tempKeyArray = [[NSMutableArray alloc] init];
        }else {
            [self.tempKeyArray removeAllObjects];
        }
        [HXBluetoothLockHelper getKeyListWithLockMac:self.bleDevice.lockMac completionBlock:^(KSHStatusCode statusCode, NSString *reason, HXKeyModel *keyObj, int total, BOOL moreData) {
            if (statusCode == KSHStatusCode_Success) {
                if (keyObj) {
                    [wself.tempKeyArray addObject:keyObj];
                }
                if (moreData) {
                    NSString *tips = [NSString stringWithFormat:NSLocalizedString(@"Syncing keys... (%d/%d)", @"同步钥匙中...（%d/%d）"), (int)wself.tempKeyArray.count, total];
                    showAlertView(tips, wself);
                }else {
                    NSString *tips = [NSString stringWithFormat:NSLocalizedString(@"Synchronization completed (%d/%d)", @"同步完成（%d/%d）"), (int)wself.tempKeyArray.count, total];
                    showDurationAlertView(tips, wself, 1.5);
                    [wself save];
                    [wself loadData];
                }
            }else {
                NSString *tips = bleCommonTips(reason, statusCode);
                showDurationAlertView(tips, wself, 2);
            }
        }];
    } animated:YES ctl:self];
}

- (void)save
{
    [HXCoreDataStackHelper deleteKeyWithLockMac:self.bleDevice.lockMac];
    for (HXKeyModel *bleKey in self.tempKeyArray) {
        [HXCoreDataStackHelper saveKey:bleKey];
    }
}


@end
