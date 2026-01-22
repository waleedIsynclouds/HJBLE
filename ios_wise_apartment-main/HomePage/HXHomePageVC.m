//
//  HXHomePageVC.m
//  HXJBLESDKDemo
//
//  Created by JQ on 2019/5/27.
//  Copyright © 2019 JQ. All rights reserved.
//

#import "HXHomePageVC.h"
#import "HXAddDeviceVC.h"
#import "HXLockDetailsVC.h"

#import "HXAddView.h"
#import "HXLockCell.h"

#import "HXCoreDataStackHelper.h"
#import "HXPushEventHelper.h"

#import <HXJBLESDK/HXBLE.h>

@interface HXHomePageVC ()

@property (nonatomic, strong) NSArray *lockArray;

@property (nonatomic, strong) HXAddView *emptyView;

@end

@implementation HXHomePageVC

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self defaultViewParams];
    
    //监听事件上报，一般情况下客户端将蓝牙锁的件上报数据转发给服务器保存
    [HXPushEventHelper sharedPushEventHelper];
}

- (void)defaultViewParams
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = NSLocalizedString(@"Device List", @"设备列表");
}

- (void)loadData
{
    NSArray<HXBLEDevice *> *deviceList = [HXCoreDataStackHelper deviceList];
    self.lockArray = deviceList;
    
    [self refreshUI];
}

- (void)refreshUI
{
    if (self.lockArray.count == 0) {
        self.emptyView.hidden = NO;
        setNaviBarRightTitleButton(nil, self, nil);
        self.view.backgroundColor = [UIColor whiteColor];
    }else {
        _emptyView.hidden = YES;
        setNaviBarRightSystemButton(UIBarButtonSystemItemAdd, self, @selector(addBtnClick));
        self.view.backgroundColor = RGB(239, 239, 245);
    }
    [self.tableView reloadData];
}

- (HXAddView *)emptyView
{
    if (!_emptyView) {
        _emptyView = [[HXAddView alloc] initWithFrame:CGRectMake(0, 0, QScreenWidth, QScreenHeight-QNavigationBarHeight) title:NSLocalizedString(@"Add Bluetooth lock", @"添加蓝牙锁")];
        [_emptyView btnAddTarget:self action:@selector(addBtnClick)];
        [self.view addSubview:_emptyView];
    }
    return _emptyView;
}

- (void)addBtnClick
{
    HXAddDeviceVC *vc = [[HXAddDeviceVC alloc] init];
    pushViewCtl(self, vc);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.lockArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HXLockCell *cell = [tableView dequeueReusableCellWithIdentifier:[HXLockCell lockCellReuseIdentifier]];
    if (!cell) {
        cell = [[HXLockCell alloc] init];
    }
    HXBLEDevice *bleDevice = self.lockArray[indexPath.row];
    cell.textLabel.text = bleDevice.lockMac;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    HXBLEDevice *bleDevice = self.lockArray[indexPath.row];
    HXLockDetailsVC *vc = [[HXLockDetailsVC alloc] initWithBLEDevice:bleDevice];
    pushViewCtl(self, vc);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
