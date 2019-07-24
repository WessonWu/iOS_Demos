//
//  UINavigationController+RTNavigation.swift
//  RTRootNavigationController-Swift
//
//  Created by wuweixin on 2019/7/22.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit

public extension RTNavigation where Base: RTRootNavigationController {
    var visibleViewController: UIViewController? {
        return base.visibleViewController.map {
            RTSafeUnwrapViewController($0)
        }
    }
    
    var topViewController: UIViewController? {
        return base.topViewController.map {
            RTSafeUnwrapViewController($0)
        }
    }
    
    var viewControllers: [UIViewController] {
        return base.viewControllers.map {
            RTSafeUnwrapViewController($0)
        }
    }
}
