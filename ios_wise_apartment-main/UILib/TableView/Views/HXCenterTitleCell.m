//
//  HXCenterTitleCell.m
//  HXJBLESDKDemo
//
//  Created by JQ on 2019/5/29.
//  Copyright © 2019 JQ. All rights reserved.
//

#import "HXCenterTitleCell.h"

@implementation HXCenterTitleCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[HXCenterTitleCell cellReuseIdentifier]];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryNone;
        self.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

+ (NSString *)cellReuseIdentifier
{
    return @"centerTitleCellReuseIdentifier";
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect textLabelFrame = self.textLabel.frame;
    textLabelFrame.origin.x = (self.frame.size.width-textLabelFrame.size.width)/2.0;
    self.textLabel.frame = textLabelFrame;
}


@end
