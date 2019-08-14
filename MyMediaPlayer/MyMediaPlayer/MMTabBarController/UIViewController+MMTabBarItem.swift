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

extension MTDWrapperController: MMTabBarDisplayble, MMToolBarDisplayble {
    public var preferredTabBarHidden: Bool {
        return mm_prefersTabBarHidden(in: contentViewController)
    }
    
    public var preferredToolBarHidden: Bool {
        return mm_prefersToolBarHidden(in: contentViewController)
    }
}

@inline(__always) func mm_prefersTabBarHidden(in vc: UIViewController) -> Bool {
    return (vc as? MMTabBarDisplayble)?.preferredTabBarHidden ?? true
}

@inline(__always) func mm_prefersToolBarHidden(in vc: UIViewController) -> Bool {
    return (vc as? MMToolBarDisplayble)?.preferredToolBarHidden ?? true
}
