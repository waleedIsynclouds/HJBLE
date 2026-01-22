//
//  HXBase64Helper.h
//  HXJBLESDKDemo
//
//  Created by JQ on 2023/4/20.
//  Copyright © 2023 JQ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXBase64Helper : NSObject

+ (NSData *)dataWithBase64Str:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
