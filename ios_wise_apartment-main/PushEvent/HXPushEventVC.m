//
//  HXPushEventVC.m
//  HXJBLESDKDemo
//
//  Created by JQ on 2019/5/30.
//  Copyright © 2019 JQ. All rights reserved.
//

#import "HXPushEventVC.h"
#import "HXPushEventHelper.h"
#import <HXJBLESDK/HXBLEDevice.h>

@interface HXPushEventVC ()

@end

@implementation HXPushEventVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadData];
    NSString *title;
    if (self.dataArray.count > 0) {
        title = [NSString stringWithFormat:NSLocalizedString(@"Bluetooth lock event report (%d)", @"蓝牙锁事件上报(%d)"),(int)self.dataArray.count];
    }else {
        title = NSLocalizedString(@"Bluetooth lock event report", @"蓝牙锁事件上报");
    }
    self.navigationItem.title = title;
    setNaviBarRightTitleButton(NSLocalizedString(@"Tips", @"提示"), self, @selector(signboardOfFriendlyTips));
}

- (void)signboardOfFriendlyTips
{
    [SHCommonFunc showAlertViewWithTitle:NSLocalizedString(@"The current page only displays the Bluetooth lock event reports received during this run of the application", @"当前页面只显示应用程序本次运行期间收到的蓝牙锁事件上报") message:nil btnTitle:NSLocalizedString(@"Got it", @"知道了") btnBlock:nil ctl:self];
}

- (void)loadData
{
    NSArray<HXRecordCellModel *> *dataArr = [[HXPushEventHelper sharedPushEventHelper] loadDataWithLockMac:self.bleDevice.lockMac];
    [self.dataArray addObjectsFromArray:dataArr];
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
    HXRecordCellModel *cellModel = [self.dataArray objectAtIndex:indexPath.row];
    return cellModel.cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"pushEventListCellReuseIdentifier";
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

@end
