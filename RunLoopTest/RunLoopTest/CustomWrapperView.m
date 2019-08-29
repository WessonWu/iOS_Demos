//
//  CustomWrapperView.m
//  RunLoopTest
//
//  Created by wuweixin on 2019/8/29.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

#import "CustomWrapperView.h"

@implementation CustomWrapperView

- (void)layoutSubviews {
    [super layoutSubviews];
    
    NSLog(@"%@: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

@end
