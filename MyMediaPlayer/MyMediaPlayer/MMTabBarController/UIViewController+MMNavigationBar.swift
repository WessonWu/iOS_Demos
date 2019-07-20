//
//  UIViewController+MMNavigationBar.swift
//  MyMediaPlayer
//
//  Created by wuweixin on 2019/7/20.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit


fileprivate var MMTabBarController_navigationBarKey: UInt8 = 0

public protocol MMNavigationBarDisplayable {
    var navigationBar: UINavigationBar { get }
    var preferredNavigationBarHidden: Bool { get }
}

extension MMNavigationBarDisplayable {
    public var preferredNavigationBarHidden: Bool {
        return false
    }
}

extension MMNavigationBarDisplayable where Self: UIViewController {
    public var navigationBar: UINavigationBar {
        return defaultNavigationBar
    }
    
    public var defaultNavigationBar: UINavigationBar {
        if let navigationBar = objc_getAssociatedObject(self, &MMTabBarController_navigationBarKey) as? UINavigationBar {
            return navigationBar
        }
        let navigationBar = UINavigationBar()
        navigationBar.layer.zPosition = CGFloat(Int.max)
        navigationBar.setItems([self.navigationItem], animated: false)
        objc_setAssociatedObject(self, &MMTabBarController_navigationBarKey, navigationBar, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return navigationBar
    }
}

extension UIViewController: MMNavigationBarDisplayable {}
