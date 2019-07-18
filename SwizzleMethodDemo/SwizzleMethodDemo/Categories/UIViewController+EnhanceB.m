//
//  UIViewController+EnhanceB.m
//  SwizzleMethodDemo
//
//  Created by wuweixin on 2019/7/18.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

#import "UIViewController+EnhanceB.h"
#import <objc/runtime.h>

@implementation UIViewController (EnhanceB)

+ (void)load {
    
    Method originalMethod1 = class_getInstanceMethod(self, @selector(viewDidLoad));
    Method swizzledMethod1 = class_getInstanceMethod(self, @selector(wwx_viewDidLoad));
    
    method_exchangeImplementations(originalMethod1, swizzledMethod1);
    
    Method originalMethod2 = class_getInstanceMethod(self, @selector(viewWillAppear:));
    Method swizzledMethod2 = class_getInstanceMethod(self, @selector(wwx_EnhanceB_viewWillAppear:));
    
    method_exchangeImplementations(originalMethod2, swizzledMethod2);
}

- (void)wwx_viewDidLoad {
    [self wwx_viewDidLoad];
    NSLog(@"UIViewController+EnhanceB: wwx_viewDidLoad");
}


- (void)wwx_EnhanceB_viewWillAppear:(BOOL)animated {
    [self wwx_EnhanceB_viewWillAppear:animated];
    NSLog(@"UIViewController+EnhanceB: wwx_EnhanceB_viewWillAppear:");
}

@end
