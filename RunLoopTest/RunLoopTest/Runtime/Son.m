//
//  Son.m
//  RunLoopTest
//
//  Created by wuweixin on 2019/9/10.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

#import "Son.h"

@implementation Son

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSLog(@"%@", NSStringFromClass([self class]));
        NSLog(@"%@", NSStringFromClass([super class]));
    }
    return self;
}

@end
