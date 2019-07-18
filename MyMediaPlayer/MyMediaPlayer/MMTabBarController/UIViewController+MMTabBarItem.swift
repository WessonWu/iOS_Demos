//
//  UIViewController+MMTabBarItem.swift
//  MyMediaPlayer
//
//  Created by wuweixin on 2019/7/18.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit

extension UIViewController {
    public var mm_tabBarItem: MMTabBarItem? {
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
    
    public var mm_tabBarController: MMTabBarController? {
        if let tabBarController = self as? MMTabBarController {
            return tabBarController
        }
        return self.parent?.mm_tabBarController
    }
}
