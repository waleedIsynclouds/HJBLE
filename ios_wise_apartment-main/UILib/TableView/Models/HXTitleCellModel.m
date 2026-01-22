//
//  HXTitleCellModel.m
//  HXJBLESDKDemo
//
//  Created by JQ on 2019/5/29.
//  Copyright © 2019 JQ. All rights reserved.
//

#import "HXTitleCellModel.h"

@implementation HXTitleCellModel

- (instancetype)initWithTitle:(NSString *)title type:(NSInteger)type
{
    self = [super init];
    if (self) {
        self.title = title;
        self.type = type;
    }
    return self;
}


@end
