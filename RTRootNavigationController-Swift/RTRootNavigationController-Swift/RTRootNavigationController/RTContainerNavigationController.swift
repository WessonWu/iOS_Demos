//
//  RTContainerNavigationController.swift
//  RTRootNavigationController-Swift
//
//  Created by wuweixin on 2019/7/22.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit


/// This Controller will forward all Navigation actions to its containing navigation controller, i.e. RTRootNavigationController.
/**
 If you are using UITabBarController in your project, it's recommand to wrap it in RTRootNavigationController as follows:
 ```
 let tabBarController = UITabBarController()
 tabBarController.viewControllers = [RTContainerNavigationController(rootViewController: vc1),
 RTContainerNavigationController(rootViewController: vc2),
 RTContainerNavigationController(rootViewController: vc3)]
 self.window?.rootViewController = tabBarController
 ```
 */
open class RTContainerNavigationController: UINavigationController {
    
    open override var delegate: UINavigationControllerDelegate? {
        get {
            if let navigationController = self.navigationController {
                return navigationController.delegate
            }
            return super.delegate
        }
        set {
            if let navigationController = self.navigationController {
                navigationController.delegate = newValue
            } else {
                super.delegate = newValue
            }
        }
    }
    
    public override init(rootViewController: UIViewController) {
        super.init(navigationBarClass: rootViewController.rt.navigationBarClass, toolbarClass: nil)
        self.pushViewController(rootViewController, animated: false)
    }
    
    public override init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        self.interactivePopGestureRecognizer?.isEnabled = false
        
        guard let rt_navigationController = self.rt.navigationController,
            rt_navigationController.transferNavigationBarAttributes else {
            return
        }
        
        if let navigationBar = self.navigationController?.navigationBar {
            self.navigationBar.isTranslucent = navigationBar.isTranslucent
            self.navigationBar.tintColor = navigationBar.tintColor
            self.navigationBar.barTintColor = navigationBar.barTintColor
            self.navigationBar.barStyle = navigationBar.barStyle
            self.navigationBar.backgroundColor = navigationBar.backgroundColor
            
            self.navigationBar.setBackgroundImage(navigationBar.backgroundImage(for: .default),
                                                  for: .default)
            self.navigationBar.setTitleVerticalPositionAdjustment(navigationBar.titleVerticalPositionAdjustment(for: .default),
                                                                  for: .default)
            
            self.navigationBar.titleTextAttributes = navigationBar.titleTextAttributes
            self.navigationBar.shadowImage = navigationBar.shadowImage
            self.navigationBar.backIndicatorImage = navigationBar.backIndicatorImage
            self.navigationBar.backIndicatorTransitionMaskImage = navigationBar.backIndicatorTransitionMaskImage
        }
    }
    
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let visibleViewController = self.visibleViewController else {
            return
        }
        
        let rt_vc = visibleViewController.rt
        if !rt_vc.hasSetInteractivePop {
            let hasSetLeftItem = visibleViewController.navigationItem.leftBarButtonItem != nil
            rt_vc.disableInteractivePop = self.isNavigationBarHidden || hasSetLeftItem
        }
        
        if let rt_containerController = self.parent as? RTContainerController,
            let rt_rootNavigationController = rt_containerController.parent as? RTRootNavigationController {
            rt_rootNavigationController.installsLeftBarButtonItemIfNeeded(for: visibleViewController)
        }
    }
    
    
    open override var tabBarController: UITabBarController? {
        guard let tabBarController = super.tabBarController else {
            return nil
        }
        
        let rt_vc = self.rt
        let rootNavigationController = rt_vc.navigationController
        if rootNavigationController?.tabBarController != tabBarController {
            return tabBarController
        }
        
        if tabBarController.tabBar.isTranslucent || rootNavigationController?.rt.viewControllers.first(where: { $0.hidesBottomBarWhenPushed }) != nil {
            return nil
        }
        
        return tabBarController
    }
    
    
    open override var viewControllers: [UIViewController] {
        get {
            if let navigationController = self.navigationController as? RTRootNavigationController {
                return navigationController.rt.viewControllers
            }
            return super.viewControllers
        }
        set {
            super.viewControllers = newValue
        }
    }
    
    open override func forUnwindSegueAction(_ action: Selector, from fromViewController: UIViewController, withSender sender: Any?) -> UIViewController? {
        if let navigationController = self.navigationController {
            return navigationController.forUnwindSegueAction(action, from: fromViewController, withSender: sender)
        }
        return super.forUnwindSegueAction(action, from: fromViewController, withSender: sender)
    }
    
    @available(iOS 9.0, *)
    open override func allowedChildrenForUnwinding(from source: UIStoryboardUnwindSegueSource) -> [UIViewController] {
        if let navigationController = self.navigationController {
            return navigationController.allowedChildrenForUnwinding(from: source)
        }
        return super.allowedChildrenForUnwinding(from: source)
    }
    
    open override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if let navigationController = self.navigationController {
            navigationController.pushViewController(viewController, animated: animated)
        } else {
            super.pushViewController(viewController, animated: animated)
        }
    }
    
    open override func forwardingTarget(for aSelector: Selector!) -> Any? {
        if let navigationController = self.navigationController, navigationController.responds(to: aSelector) {
            return navigationController
        }
        return nil
    }
    
    open override func popViewController(animated: Bool) -> UIViewController? {
        if let navigationController = self.navigationController {
            return navigationController.popViewController(animated: animated)
        }
        return super.popViewController(animated: animated)
    }
    
    open override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        if let navigationController = self.navigationController {
            return navigationController.popToRootViewController(animated: animated)
        }
        return super.popToRootViewController(animated: animated)
    }
    
    open override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        if let navigationController = self.navigationController {
            return navigationController.popToViewController(viewController, animated: animated)
        }
        return super.popToViewController(viewController, animated: animated)
    }
    
    open override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        if let navigationController = self.navigationController {
            navigationController.setViewControllers(viewControllers, animated: animated)
        } else {
            super.setViewControllers(viewControllers, animated: animated)
        }
    }
    
    
    open override func setNavigationBarHidden(_ hidden: Bool, animated: Bool) {
        super.setNavigationBarHidden(hidden, animated: animated)
        
        guard let visibleViewController = self.visibleViewController else {
            return
        }
        let rt_vc = visibleViewController.rt
        if !rt_vc.hasSetInteractivePop {
            rt_vc.disableInteractivePop = hidden
        }
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? super.preferredStatusBarStyle
    }
    
    open override var prefersStatusBarHidden: Bool {
        return topViewController?.prefersStatusBarHidden ?? super.prefersStatusBarHidden
    }
    
    open override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return topViewController?.preferredStatusBarUpdateAnimation ?? super.preferredStatusBarUpdateAnimation
    }
    
    @available(iOS 11.0, *)
    open override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return topViewController?.preferredScreenEdgesDeferringSystemGestures ?? super.preferredScreenEdgesDeferringSystemGestures
    }
    
    @available(iOS 11.0, *)
    open override var childForScreenEdgesDeferringSystemGestures: UIViewController? {
        return topViewController?.childForScreenEdgesDeferringSystemGestures ?? super.childForScreenEdgesDeferringSystemGestures
    }
    
    @available(iOS 11.0, *)
    open override var prefersHomeIndicatorAutoHidden: Bool {
        return topViewController?.prefersHomeIndicatorAutoHidden ?? super.prefersHomeIndicatorAutoHidden
    }
    
    @available(iOS 11.0, *)
    open override var childForHomeIndicatorAutoHidden: UIViewController? {
        return topViewController
    }
}
