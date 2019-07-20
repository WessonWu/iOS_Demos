//
//  UIViewController+MMNavigationBar.swift
//  MyMediaPlayer
//
//  Created by wuweixin on 2019/7/20.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit


fileprivate var MMTabBarController_navigationBarKey: UInt8 = 0
fileprivate var MMTabBarController_navigationBarDelegateKey: UInt8 = 0

extension UIViewController {
    @objc
    public var mm_navigationBar: UINavigationBar {
        if let navigationBar = objc_getAssociatedObject(self, &MMTabBarController_navigationBarKey) as? UINavigationBar {
            navigationBar.setItems([self.navigationItem], animated: false)
            return navigationBar
        }
        let navigationBar = UINavigationBar()
        navigationBar.delegate = self.mm_navigationBarDelegate
        objc_setAssociatedObject(self, &MMTabBarController_navigationBarKey, navigationBar, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        navigationBar.setItems([self.navigationItem], animated: false)
        navigationBar.isHidden = mm_preferredNavigationBarHidden
        return navigationBar
    }
    
    @objc
    public var mm_preferredNavigationBarHidden: Bool {
        return false
    }
    
    @objc
    public var mm_navigationBarDelegate: UINavigationBarDelegate? {
        if let delegate = objc_getAssociatedObject(self, &MMTabBarController_navigationBarDelegateKey) as? UINavigationBarDelegate {
            return delegate
        }
        let delegate = MMNavigationBarDelegateProxy()
        objc_setAssociatedObject(self, &MMTabBarController_navigationBarDelegateKey, delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return delegate
    }
}

public class MMNavigationBarDelegateProxy: NSObject, UINavigationBarDelegate {
    public func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    public func navigationBar(_ navigationBar: UINavigationBar, shouldPush item: UINavigationItem) -> Bool {
        return true
    }
    
    public func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        return false
    }
    
    public func navigationBar(_ navigationBar: UINavigationBar, didPush item: UINavigationItem) {
        
    }
    
    public func navigationBar(_ navigationBar: UINavigationBar, didPop item: UINavigationItem) {
        
    }
}
