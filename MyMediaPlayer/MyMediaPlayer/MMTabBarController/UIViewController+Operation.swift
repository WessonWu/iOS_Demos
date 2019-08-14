//
//  UIViewController+Operation.swift
//  MyMediaPlayer
//
//  Created by wuweixin on 2019/8/14.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit

public protocol PresentedViewControllerPushable: UIViewController {}

extension UIViewController {
    open var mm_pendingPresentedViewController: UIViewController? {
        get {
            return mm_getWeakAssociatedObject(self, key: &AssociatedKeys.pendingPresentedViewController)
        }
        set {
            let oldValue = self.mm_pendingPresentedViewController
            oldValue?.mm_pendingPresentingViewController = nil
            newValue?.mm_pendingPresentingViewController = self
            mm_setWeakAssociatedObject(self, key: &AssociatedKeys.pendingPresentedViewController, value: newValue)
        }
    }
    
    open var mm_pendingPresentingViewController: UIViewController? {
        get {
            return mm_getWeakAssociatedObject(self, key: &AssociatedKeys.pendingPresentingViewController)
        }
        set {
            mm_setWeakAssociatedObject(self, key: &AssociatedKeys.pendingPresentingViewController, value: newValue)
        }
    }
}

// not include UISplitViewController
public extension UIViewController {
    class func topMostViewController(for viewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = viewController as? UINavigationController {
            return topMostViewController(for: navigationController.visibleViewController)
        }
        if let tabBarController = viewController as? UITabBarController {
            if let selectedViewController = tabBarController.selectedViewController {
                return topMostViewController(for: selectedViewController)
            }
        }
        if let presentedViewController = viewController?.presentedViewController {
            return topMostViewController(for: presentedViewController)
        }
        return viewController
    }
    
    class func pushAsPossible(_ viewControllerToPush: UIViewController, animated: Bool = true) {
        guard let topMostVC = UIViewController.topMostViewController() else {
            return
        }
        
        topMostVC.safePush(viewControllerToPush, animated: animated)
    }
    
    func navigationControllerForPushAsPossible(_ viewControllerToPush: UIViewController) -> UINavigationController? {
        if let navigationController = self.navigationController {
            return navigationController
        }
        if let _ = self as? PresentedViewControllerPushable,
            let navigationController = self.presentingViewController?.topMostNavigaitonController() {
            return navigationController
        }
        return nil
    }
    
    func safePush(_ viewControllerToPush: UIViewController, animated: Bool = true) {
        if let navigationController = self.navigationController {
            navigationController.pushViewController(viewControllerToPush, animated: animated)
            return
        }
        
        if let _ = self as? PresentedViewControllerPushable,
            let navigationController = self.presentingViewController?.topMostNavigaitonController() {
            navigationController.topViewController?.mm_pendingPresentedViewController = self
            self.dismiss(animated: false)
            navigationController.pushViewController(viewControllerToPush, animated: animated)
        }
    }
    
    func safePresent(_ viewControllerToPresent: UIViewController, animated: Bool = true, completion: (() -> Void)?) {
        // check the viewControllerToPresent has already presented.
        viewControllerToPresent.mm_pendingPresentingViewController?.mm_pendingPresentedViewController = nil
        guard viewControllerToPresent.presentingViewController == nil else {
            completion?()
            return
        }
        self.present(viewControllerToPresent, animated: animated, completion: completion)
    }
    
    func topMostNavigaitonController() -> UINavigationController? {
        if let navigationController = self as? UINavigationController {
            return navigationController
        }
        if let navigationController = self.navigationController {
            return navigationController
        }
        if let tabBarController = self as? UITabBarController {
            return tabBarController.selectedViewController?.topMostNavigaitonController()
        }
        return nil
    }
}

@inline(__always) func mm_getWeakAssociatedObject<Value>(_ object: Any, key: UnsafeRawPointer) -> Value? where Value: AnyObject {
    return (objc_getAssociatedObject(object, key) as? WeakReference<Value>)?.value
}

@inline(__always) func mm_setWeakAssociatedObject<Value>(_ object: Any, key: UnsafeRawPointer, value: Value?) where Value: AnyObject {
    return objc_setAssociatedObject(object, key, WeakReference<Value>(value), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
}
