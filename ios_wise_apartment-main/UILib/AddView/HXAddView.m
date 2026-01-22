//
//  HXAddView.m
//  HXJBLESDKDemo
//
//  Created by JQ on 2019/5/27.
//  Copyright © 2019 JQ. All rights reserved.
//

#import "HXAddView.h"

@implementation HXAddView
{
    UIButton *_btn;
}

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addBtnWithTitle:title];
    }
    return self;
}

- (void)addBtnWithTitle:(NSString *)title
{
    CGFloat originY = (self.bounds.size.height-44)/2.0;
    _btn = [[UIButton alloc] initWithFrame:CGRectMake(30, originY, self.frame.size.width-60, 50)];
    _btn.backgroundColor = [UIColor whiteColor];
    _btn.layer.cornerRadius = 25;
    _btn.layer.shadowColor = RGB(230, 230, 240).CGColor;
    _btn.layer.shadowOpacity = 0.99;
    _btn.layer.shadowOffset = CGSizeMake(0,2);
    _btn.layer.shadowRadius = 25;

    [_btn setTitle:title forState:UIControlStateNormal];
    [_btn setTitleColor:RGB(100, 100, 100) forState:UIControlStateNormal];
    [_btn setTitleColor:RGBA(100, 100, 100, 0.5) forState:UIControlStateHighlighted];
    
    [self addSubview:_btn];
}

- (void)btnAddTarget:(id)target action:(SEL)action;
{
    [_btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
