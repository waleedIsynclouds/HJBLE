//
//  HXSectionModel.m
//  HXJBLESDKDemo
//
//  Created by JQ on 2019/5/29.
//  Copyright © 2019 JQ. All rights reserved.
//

#import "HXSectionModel.h"

@implementation HXSectionModel


- (instancetype)init
{
    self = [super init];
    if (self) {
        _cellModelArr = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addCellModel:(id)cellModel
{
    if (cellModel) {
        [_cellModelArr addObject:cellModel];
    }
}

- (id)cellModelAtIndex:(NSInteger)index
{
    if (_cellModelArr.count > index) {
        return [_cellModelArr objectAtIndex:index];
    }
    return nil;
}

@end
