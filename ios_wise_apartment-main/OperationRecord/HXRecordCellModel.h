//
//  HXRecordCellModel.h
//  HXJBLESDKDemo
//
//  Created by JQ on 2019/5/30.
//  Copyright © 2019 JQ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class HXRecordBaseModel;

@interface HXRecordCellModel : NSObject

@property (nonatomic, strong) id obj;

@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) NSString *details;

@property (nonatomic, assign) CGFloat cellHeight;

@end

NS_ASSUME_NONNULL_END
