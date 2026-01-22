//
//  HXLockCell.m
//  HXJBLESDKDemo
//
//  Created by JQ on 2019/5/28.
//  Copyright © 2019 JQ. All rights reserved.
//

#import "HXLockCell.h"

@implementation HXLockCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[HXLockCell lockCellReuseIdentifier]];
    if (self) {
        self.imageView.image = [UIImage imageNamed:@"lockicon"];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}

+ (NSString *)lockCellReuseIdentifier
{
    return @"lockCellReuseIdentifier";
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat iconWidth = 80;
    self.imageView.frame = CGRectMake(10, (CGRectGetHeight(self.frame)-iconWidth)/2.0, iconWidth, iconWidth);
    CGRect textLabelFrame = self.textLabel.frame;
    textLabelFrame.origin.x = CGRectGetMaxX(self.imageView.frame)+10;
    self.textLabel.frame = textLabelFrame;
}

@end
