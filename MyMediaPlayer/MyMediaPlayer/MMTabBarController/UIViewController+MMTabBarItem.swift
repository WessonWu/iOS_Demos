//
//  UIViewController+MMTabBarItem.swift
//  MyMediaPlayer
//
//  Created by wuweixin on 2019/7/18.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit
import MTDNavigationView

extension UIViewController {
    open var mm_tabBarItem: MMTabBarItem? {
        get {
            guard let tabBarController = self.mm_tabBarController, tabBarController.selectedViewController != nil else {
                return nil
            }
            
            return tabBarController.tabBar.selectedItem
        }
        set {
            guard let tabBarItem = newValue, let tabBarController = self.mm_tabBarController else {
                return
            }
            
            let index = tabBarController.selectedIndex
            if index >= 0 && index < tabBarController.tabBar.items.count {
                tabBarController.tabBar.items[index] = tabBarItem
            }
        }
    }
    
    open var mm_tabBarController: MMTabBarController? {
        if let tabBarController = self as? MMTabBarController {
            return tabBarController
        }
        return self.parent?.mm_tabBarController
    }
}

extension UIViewController {
    open var pendingPresentedViewController: UIViewController? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.pendingPresentedViewController) as? UIViewController
        }
        set {
            let oldValue = self.pendingPresentedViewController
            oldValue?.pendingPresentingViewController = nil
            newValue?.pendingPresentingViewController = self
            objc_setAssociatedObject(self, &AssociatedKeys.pendingPresentedViewController, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    open var pendingPresentingViewController: UIViewController? {
        get {
            if let vcRef = objc_getAssociatedObject(self, &AssociatedKeys.pendingPresentingViewController) as? ViewControllerRef {
                return vcRef.value
            }
            return nil
        }
        set {
            var value: ViewControllerRef? = nil
            if let vc = newValue {
                value = ViewControllerRef(vc)
            }
            objc_setAssociatedObject(self, &AssociatedKeys.pendingPresentingViewController, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

extension MTDWrapperController: MMTabBarDisplayble, MMToolBarDisplayble {
    public var preferredTabBarHidden: Bool {
        return prefersTabBarHidden(in: contentViewController)
    }
    
    public var preferredToolBarHidden: Bool {
        return prefersToolBarHidden(in: contentViewController)
    }
}


@inline(__always) func prefersTabBarHidden(in vc: UIViewController) -> Bool {
    return (vc as? MMTabBarDisplayble)?.preferredTabBarHidden ?? true
}

@inline(__always) func prefersToolBarHidden(in vc: UIViewController) -> Bool {
    return (vc as? MMToolBarDisplayble)?.preferredToolBarHidden ?? true
}
