//
//  UIViewController+RDVTabBarControllerItem.swift
//  RDVTabBarController-Swift
//
//  Created by wuweixin on 2019/7/17.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit

fileprivate var RDVTabBarControllerKey: UInt8 = 0

extension UIViewController {
    public var rdv_tabBarItem: RDVTabBarItem? {
        get {
            guard let tabBarController = self.rdv_tabBarController, let index = tabBarController.index(for: self) else {
                return nil
            }
            
            return tabBarController.tabBar.tabBarItem(at: index)
        }
        set {
            guard let tabBarItem = newValue,
                let tabBarController = self.rdv_tabBarController,
                let index = tabBarController.index(for: self) else {
                return
            }
            
            if index >= 0 && index < tabBarController.tabBar.items.count {
                tabBarController.tabBar.items[index] = tabBarItem
            }
        }
    }
    
    public internal(set) var rdv_tabBarController: RDVTabBarController? {
        get {
            if let tabBarController = objc_getAssociatedObject(self, &RDVTabBarControllerKey) as? RDVTabBarController {
                return tabBarController
            }
            return self.parent?.rdv_tabBarController
        }
        set {
            objc_setAssociatedObject(self, &RDVTabBarControllerKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
}
