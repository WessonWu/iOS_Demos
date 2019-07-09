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
        super.pushViewController(viewController, animated: animated)
    }
}

extension CommonNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let shouldTabbarHidden = navigationController.shouldTabbarHidden
        guard let tabbarVC = viewController.tabBarController, shouldTabbarHidden != tabbarVC.tabBar.isHidden else {
            return
        }
        let tabbar = tabbarVC.tabBar
        tabbar.isHidden = false
        if let transitionCoordinator = viewController.transitionCoordinator {
            let startTransform: CGAffineTransform
            let endTransform: CGAffineTransform
            if shouldTabbarHidden {
                startTransform = .identity
                endTransform = CGAffineTransform(translationX: 0, y: tabbar.frame.height)
            } else {
                startTransform = CGAffineTransform(translationX: 0, y: tabbar.frame.height)
                endTransform = .identity
            }
            tabbar.transform = startTransform
            transitionCoordinator.animate(alongsideTransition: { (context) in
                tabbar.transform = endTransform
            }) { (context) in
                tabbar.transform = .identity
                tabbar.isHidden = navigationController.viewControllers.count > 1
            }
        } else {
            tabbar.transform = .identity
            tabbar.isHidden = navigationController.viewControllers.count > 1
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
