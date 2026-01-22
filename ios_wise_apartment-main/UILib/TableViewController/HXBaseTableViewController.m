//
//  HXBaseTableViewController.m
//  HXJBLESDKDemo
//
//  Created by JQ on 2019/5/29.
//  Copyright © 2019 JQ. All rights reserved.
//

#import "HXBaseTableViewController.h"

@interface HXBaseTableViewController ()

@end

@implementation HXBaseTableViewController

- (instancetype)initWithBLEDevice:(HXBLEDevice *)bleDevice
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.bleDevice = bleDevice;
        _dataArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

@end
