//
//  CommonNavigationController.swift
//  ToolbarController
//
//  Created by wuweixin on 2019/7/9.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit

class CommonNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setToolbarItems([UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(cameraButtonClick(_:)))], animated: false)
//        self.setToolbarHidden(false, animated: false)
        self.delegate = self
    }
    
    
    @objc
    private func cameraButtonClick(_ sender: Any) {
        print(#function)
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        viewController.hidesBottomBarWhenPushed = true
        super.pushViewController(viewController, animated: animated)
        if viewControllers.first == viewController {
            viewController.hidesBottomBarWhenPushed = false
        }
    }
}

extension CommonNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        let shouldTabbarHidden = navigationController.shouldTabbarHidden
        let tabBarVC = self.tabBarController
        if let transitionCoordinator = viewController.transitionCoordinator {
            if let job = tabBarVC?.tabBarAnimationsWorkItemWithHidden(shouldTabbarHidden) {
                transitionCoordinator.animate(alongsideTransition: { (_) in
                    job.animations()
                }) { (context) in
                    job.completion(!context.isCancelled)
                }
            }
        } else {
            tabBarVC?.setTabBarHidden(shouldTabbarHidden, animated: false)
        }
    }
    
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        
    }
}

extension UINavigationController {
    var shouldTabbarHidden: Bool {
        return viewControllers.count > 1
    }
}
