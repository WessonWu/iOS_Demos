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
        self.interactivePopGestureRecognizer?.delegate = self
        self.delegate = self
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if viewControllers.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: animated)
    }
}


extension CommonNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard let tabBarVC = self.tabBarController,
            !tabBarVC.tabBar.isHidden else {
            return
        }
     
        let tabBar = tabBarVC.tabBar
        
        let startTransform: CGAffineTransform
        let endTransform: CGAffineTransform
        if viewController.hidesBottomBarWhenPushed {
            startTransform = .identity
            endTransform = CGAffineTransform(translationX: 0, y: tabBar.frame.height)
        } else {
            startTransform = CGAffineTransform(translationX: 0, y: tabBar.frame.height)
            endTransform = .identity
        }
        
        let containerView: UIView = tabBarVC.view
        tabBar.removeFromSuperview()
        containerView.addSubview(tabBar)
        tabBar.layer.zPosition = 100
        tabBar.transform = startTransform
        let animations: () -> Void = {
            tabBar.transform = endTransform
        }

        let completions: () -> Void = {
            tabBar.transform = .identity
        }
        
        if animated {
            viewController.transitionCoordinator?.animateAlongsideTransition(in: containerView, animation: { (context) in
                animations()
            }, completion: { (context) in
                completions()
            })
        } else {
            UIView.performWithoutAnimation(animations)
            DispatchQueue.main.async(execute: completions)
        }
    }
}


extension CommonNavigationController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
