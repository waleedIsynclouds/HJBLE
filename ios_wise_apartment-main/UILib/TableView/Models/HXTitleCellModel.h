//
//  HXTitleCellModel.h
//  HXJBLESDKDemo
//
//  Created by JQ on 2019/5/29.
//  Copyright © 2019 JQ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXTitleCellModel : NSObject

- (instancetype)initWithTitle:(NSString *)title type:(NSInteger)type;

@property (nonatomic, strong) NSString *title;

@property (nonatomic, assign) NSInteger type;

//可选
@property (nonatomic, strong) id obj;

//可选
@property (nonatomic, strong) NSString *details;

//可选
@property (nonatomic, assign) int value;

@end

NS_ASSUME_NONNULL_END
