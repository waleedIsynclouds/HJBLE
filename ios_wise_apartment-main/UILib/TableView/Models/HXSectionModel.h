//
//  HXSectionModel.h
//  HXJBLESDKDemo
//
//  Created by JQ on 2019/5/29.
//  Copyright © 2019 JQ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXSectionModel : NSObject

@property (nonatomic, strong) NSMutableArray *cellModelArr;

- (void)addCellModel:(id)cellModel;

- (id)cellModelAtIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
