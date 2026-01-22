//
//  HXVerticalAlignmentLabel.m
//  HXJBLESDKDemo
//
//  Created by JQ on 2019/5/27.
//  Copyright © 2019 JQ. All rights reserved.
//

#import "HXVerticalAlignmentLabel.h"

@implementation HXVerticalAlignmentLabel

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.verticalAlignment = KLabelVerticalAlignmentMiddle;
        self.numberOfLines = 0;
    }
    return self;
}

- (void)setVerticalAlignment:(KLabelVerticalAlignment)verticalAlignment
{
    _verticalAlignment = verticalAlignment;
    [self setNeedsDisplay];
}

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines
{
    CGRect textRect = [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
    switch (self.verticalAlignment) {
        case KLabelVerticalAlignmentTop:
            textRect.origin.y = bounds.origin.y;
            break;
        case KLabelVerticalAlignmentBottom:
            textRect.origin.y = bounds.origin.y + bounds.size.height - textRect.size.height;
            break;
        case KLabelVerticalAlignmentMiddle:
        default:
            textRect.origin.y = bounds.origin.y + (bounds.size.height - textRect.size.height) / 2.0;
    }
    return textRect;
}

- (void)drawTextInRect:(CGRect)rect
{
    CGRect actualRect = [self textRectForBounds:rect limitedToNumberOfLines:self.numberOfLines];
    [super drawTextInRect:actualRect];
}

@end
