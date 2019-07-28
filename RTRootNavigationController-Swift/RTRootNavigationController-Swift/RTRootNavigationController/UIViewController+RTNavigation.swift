//
//  UIViewController+RTNavigation.swift
//  RTRootNavigationController-Swift
//
//  Created by wuweixin on 2019/7/24.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit

extension UIViewController: RTNavigationCompatible {}

internal struct AssociatedKeys {
    static var disableInteractivePop = "rt_disableInteractivePop"
}

public extension RTNavigation where Base: UIViewController {
    var navigationController: RTRootNavigationController? {
        var vc: UIViewController = self.base
        while !vc.isKind(of: RTRootNavigationController.self) {
            guard let navigationController = vc.navigationController else {
                return nil
            }
            vc = navigationController
        }
        return vc as? RTRootNavigationController
    }
    
    
    var unwrapped: UIViewController {
        return RTSafeUnwrapViewController(base)
    }
    
    var navigationBarClass: AnyClass? {
        return (base as? RTNavigationBarCustomizable)?.navigationBarClass
    }
    
    var disableInteractivePop: Bool {
        get {
            return objc_getAssociatedObject(base, &AssociatedKeys.disableInteractivePop) as? Bool ?? false
        }
        
        set {
            objc_setAssociatedObject(base, &AssociatedKeys.disableInteractivePop, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    func customBackItemWithTarget(_ target: Any?, action: Selector) -> UIBarButtonItem? {
        return (base as? RTNavigationItemCustomizable)?.customBackItemWithTarget(target, action: action)
    }
}


internal extension RTNavigation where Base: UIViewController {
    var hasSetInteractivePop: Bool {
        return (objc_getAssociatedObject(base, &AssociatedKeys.disableInteractivePop) as? Bool) != nil
    }
}
