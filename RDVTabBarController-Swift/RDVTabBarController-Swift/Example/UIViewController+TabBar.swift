//
//  UIViewController+TabBar.swift
//  RDVTabBarController-Swift
//
//  Created by wuweixin on 2019/7/18.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit

fileprivate var RDVTabBarController_rdv_preferredTabBarHiddenKey: UInt8 = 0

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
    
    
    var rdv_preferredTabBarHidden: Bool {
        get {
            return objc_getAssociatedObject(self, &RDVTabBarController_rdv_preferredTabBarHiddenKey) as? Bool ?? false
        }
        
        set {
            objc_setAssociatedObject(self, &RDVTabBarController_rdv_preferredTabBarHiddenKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    
    fileprivate class func swizzleMethods() {
        method_exchangeImplementations(
            class_getInstanceMethod(self, #selector(UIViewController.viewWillAppear(_:)))!,
            class_getInstanceMethod(self, #selector(UIViewController.RDVTabBarController_viewWillAppear(_:)))!)
    }
    
    @objc
    func RDVTabBarController_viewWillAppear(_ animated: Bool) {
        self.RDVTabBarController_viewWillAppear(animated)
        
        if let tabBarVC = self.rdv_tabBarController {
            tabBarVC.setTabBarHidden(rdv_preferredTabBarHidden, animated: animated)
        }
    }
}
