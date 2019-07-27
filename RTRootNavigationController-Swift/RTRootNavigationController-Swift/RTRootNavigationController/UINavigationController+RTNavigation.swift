//
//  UINavigationController+RTNavigation.swift
//  RTRootNavigationController-Swift
//
//  Created by wuweixin on 2019/7/22.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit

public extension RTNavigation where Base: RTRootNavigationController {
    /// use this property instead of @c visibleViewController to get the current visiable content view controller
    var visibleViewController: UIViewController? {
        return base.visibleViewController.map {
            RTSafeUnwrapViewController($0)
        }
    }
    
    /// use this property instead of @c topViewController to get the content view controller on the stack top
    var topViewController: UIViewController? {
        return base.topViewController.map {
            RTSafeUnwrapViewController($0)
        }
    }
    
    /// use this property to get all the content view controllers;
    var viewControllers: [UIViewController] {
        return base.viewControllers.map {
            RTSafeUnwrapViewController($0)
        }
    }
}
