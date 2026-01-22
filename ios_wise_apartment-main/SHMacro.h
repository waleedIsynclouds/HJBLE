//
//  SHMacro.h
//  DeviceConfigDemo
//
//  Created by JQ on 2018/3/29.
//  Copyright © 2018年 JQ. All rights reserved.
//

#ifndef SHMacro_h
#define SHMacro_h

#define QScreenWidth [UIScreen mainScreen].bounds.size.width
#define QScreenHeight [UIScreen mainScreen].bounds.size.height
#define QStatusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height
#define QNavigationBarHeight (QStatusBarHeight+44)

#define RGB(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

#define QCommonStyleColor RGB(66, 106, 255)

#define KSH_iPhoneXScreen ((fabs((double)QScreenHeight - (double)812) < DBL_EPSILON ) || (fabs((double)QScreenWidth - (double)812) < DBL_EPSILON )) ||\
((fabs((double)QScreenHeight - (double)896) < DBL_EPSILON ) || (fabs((double)QScreenWidth - (double)896) < DBL_EPSILON ))

#define safeArea (KSH_iPhoneXScreen ? 34 : 0)

#endif /* SHMacro_h */
