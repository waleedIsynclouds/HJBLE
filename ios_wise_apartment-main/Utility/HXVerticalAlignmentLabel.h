//
//  HXVerticalAlignmentLabel.h
//  HXJBLESDKDemo
//
//  Created by JQ on 2019/5/27.
//  Copyright © 2019 JQ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, KLabelVerticalAlignment) {
    KLabelVerticalAlignmentTop = 0,
    KLabelVerticalAlignmentMiddle,
    KLabelVerticalAlignmentBottom,
};

@interface HXVerticalAlignmentLabel : UILabel

/**
 *  默认KLabelVerticalAlignmentMiddle
 */
@property (nonatomic, assign) KLabelVerticalAlignment verticalAlignment;

@end

NS_ASSUME_NONNULL_END
