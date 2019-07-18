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


extension UIApplication {
    override open var next: UIResponder? {
        UIViewController.awake
        return super.next
    }
}

extension UIViewController {
    static let awake: Void = {
        swizzleMethods()
    }()
    
    fileprivate class func swizzleMethods() {
        method_exchangeImplementations(
            class_getInstanceMethod(self, #selector(UIViewController.viewWillAppear(_:)))!,
            class_getInstanceMethod(self, #selector(UIViewController.MMTabBarController_viewWillAppear(_:)))!)
    }
    
    @objc
    func MMTabBarController_viewWillAppear(_ animated: Bool) {
        self.MMTabBarController_viewWillAppear(animated)
        
        guard !self.isKind(of: UITabBarController.self) && !self.isKind(of: UINavigationController.self) && !self.isKind(of: MMTabBarRootViewController.self) else {
            return
        }
        
        if let tabBarVC = self.mm_tabBarController {
            var shouldSongViewHidden = true
            var shouldTabBarHidden = true
            if let displayable = self as? MMBottomBarDisplayable {
                shouldSongViewHidden = displayable.shouldSongViewHidden
                shouldTabBarHidden = displayable.shouldTabBarHidden
            }
            tabBarVC.setBottomBarHidden(isSongViewHidden: shouldSongViewHidden, isTabBarHidden: shouldTabBarHidden, animated: animated)
        }
    }
}

