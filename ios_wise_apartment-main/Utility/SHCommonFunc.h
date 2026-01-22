//
//  SHCommonFunc.h
//  DeviceConfigDemo
//
//  Created by JQ on 2018/8/11.
//  Copyright © 2018年 JQ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SHCommonFunc : NSObject

CGSize stringSize(NSString *text, CGSize limitSize, CGFloat fontSize);

void showAlertView(NSString *title, UIViewController *ctl);

void showDurationAlertView(NSString *title, UIViewController *ctl, CGFloat duration);

void showCompletionBlockAlertView(NSString *title, UIViewController *ctl, CGFloat duration, void(^completion)(void));

void dismissAlertView(UIViewController *ctl);

+ (UIAlertController *)showAlertViewWithTitle:(NSString *)title
                                      message:(NSString *)message
                                     btnTitle:(NSString *)btnTitle
                                     btnBlock:(void(^)(void))block
                                          ctl:(UIViewController *)ctl;

+ (UIAlertController *)showAlertViewWithTitle:(NSString *)title
                                      message:(NSString *)message
                                    btn1Title:(NSString *)btn1Title
                                    btn2Title:(NSString *)btn2Title
                                    btn1Block:(void(^)(void))btn1Block
                                    btn2Block:(void(^)(void))btn2Block
                                     animated:(BOOL)animated
                                          ctl:(UIViewController *)ctl;

+ (UIAlertController *)showTextFieldAlertViewWithTitle:(NSString *)title
                                               message:(NSString *)message
                                          confirmTitle:(NSString *)confirmTitle
                               textFieldConfigureBlock:(void(^)(UITextField *textField))textFieldConfigureBlock
                                          confirmBlock:(void(^)(UITextField *textField))confirmBlock
                                                   ctl:(UIViewController *)ctl;

void setNaviBarRightTitleButton(NSString *title, UIViewController *vc, SEL sel);
void setNaviBarRightTitleColorButton(NSString *title, UIViewController *vc, SEL sel, UIColor *tintColor);
void setNaviBarRightSystemButton(UIBarButtonSystemItem systemItem, UIViewController *vc, SEL sel);

void pushViewCtl(UIViewController *currentCtl, UIViewController *pushCtl);

NSString *bleCommonTips(NSString *reason, NSInteger statusCode);

@end
