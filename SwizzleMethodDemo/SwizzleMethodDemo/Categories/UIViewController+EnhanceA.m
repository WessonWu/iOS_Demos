//
//  UIViewController+EnhanceA.m
//  SwizzleMethodDemo
//
//  Created by wuweixin on 2019/7/18.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

#import "UIViewController+EnhanceA.h"
#import <objc/runtime.h>

@implementation UIViewController (EnhanceA)

+ (void)load {
    Method originalMethod1 = class_getInstanceMethod(self, @selector(viewDidLoad));
    Method swizzledMethod1 = class_getInstanceMethod(self, @selector(wwx_viewDidLoad));
    
    method_exchangeImplementations(originalMethod1, swizzledMethod1);
    
    Method originalMethod2 = class_getInstanceMethod(self, @selector(viewWillAppear:));
    Method swizzledMethod2 = class_getInstanceMethod(self, @selector(wwx_EnhanceA_viewWillAppear:));
    
    method_exchangeImplementations(originalMethod2, swizzledMethod2);
}

- (void)wwx_viewDidLoad {
    [self wwx_viewDidLoad];
    NSLog(@"UIViewController+EnhanceA: wwx_viewDidLoad");
}


- (void)wwx_EnhanceA_viewWillAppear:(BOOL)animated {
    [self wwx_EnhanceA_viewWillAppear:animated];
    NSLog(@"UIViewController+EnhanceA: wwx_EnhanceA_viewWillAppear:");
}

@end
