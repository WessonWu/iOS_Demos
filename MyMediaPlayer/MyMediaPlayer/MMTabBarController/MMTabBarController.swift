//
//  MMTabBarController.swift
//  MyMediaPlayer
//
//  Created by wuweixin on 2019/7/18.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import MTDNavigationView

public protocol MMTabBarControllerDelegate: AnyObject {
    /// Asks the delegate whether the specified view controller should be made active.
    func tabBarController(_ tabBarController: MMTabBarController, shouldSelect viewController: UIViewController) -> Bool
    
    /// Tells the delegate that the user selected an item in the tab bar.
    func tabBarController(_ tabBarController: MMTabBarController, didSelect viewController: UIViewController)
    
    /// Tells the delegate that the user tap on the selected item in the tab bar.
    func tabBarController(_ tabBarController: MMTabBarController, didSelectItemAt index: Int)
}

public extension MMTabBarControllerDelegate {
    func tabBarController(_ tabBarController: MMTabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true
    }
    func tabBarController(_ tabBarController: MMTabBarController, didSelect viewController: UIViewController) {}
    func tabBarController(_ tabBarController: MMTabBarController, didSelectItemAt index: Int) {}
}

open class MMTabBarController: MTDNavigationController, MMTabBarDelegate {
    
    open weak var tabBarControllerDelegate: MMTabBarControllerDelegate?
    
    open var tabBarViewControllers: [UIViewController] {
        get {
            return rootViewController.viewControllers
        }
        set {
            rootViewController.viewControllers = newValue
        }
    }
    
    open var selectedIndex: Int {
        get {
            return rootViewController.selectedIndex
        }
        set {
            rootViewController.selectedIndex = newValue
        }
    }
    
    open var selectedViewController: UIViewController? {
        return rootViewController.selectedViewController
    }
    
    open var tabBar: MMTabBar {
        return bottomBar.tabBar
    }
    
    open private(set) lazy var bottomBar: MMBottomBar = {
        let bottomBar = MMBottomBar()
        bottomBar.autoresizingMask = [.flexibleWidth,
                                   .flexibleTopMargin,
                                   .flexibleBottomMargin]
        bottomBar.tabBar.delegate = self
        return bottomBar
    }()
    
    
    lazy var rootViewController: MMTabBarRootViewController = MMTabBarRootViewController(with: self)
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return topViewController?.supportedInterfaceOrientations ?? super.supportedInterfaceOrientations
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        rootViewController.mtd.navigationView.isHidden = true
        self.viewControllers = [rootViewController]
        self.view.addSubview(bottomBar)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let index = self.selectedIndex
        self.selectedIndex = index
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bottomBar.frame = finalFrameForBottomBar()
        self.automaticallyAdjustsInsetsIfNeeded()
    }
    
    
    func automaticallyAdjustsInsetsIfNeeded() {
        guard let topVC = self.topViewController else {
            return
        }
        
        let shouldAdjustsScrollInsets = !bottomBar.isBottomBarHidden
        if #available(iOS 11.0, *) {
            if shouldAdjustsScrollInsets {
                topVC.adjustedSafeAreaInsetBottom = bottomBar.frame.height - self.view.safeAreaInsets.bottom
            } else {
                topVC.adjustedSafeAreaInsetBottom = 0
            }
        } else {
            if shouldAdjustsScrollInsets && self.automaticallyAdjustsScrollViewInsets {
                topVC.adjustsScrollViewInsets(bottom: bottomBar.frame.height)
            } else {
                topVC.adjustsScrollViewInsets(bottom: 0)
            }
        }
    }
    
    @available(iOS 11.0, *)
    open override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        self.automaticallyAdjustsInsetsIfNeeded()
    }
    
    open func tabBar(_ tabBar: MMTabBar, shouldSelectItemAt index: Int) -> Bool {
        guard let viewController = rootViewController.viewController(at: index) else {
            return false
        }
        let shouldSelectItem = self.tabBarControllerDelegate?.tabBarController(self, shouldSelect: viewController) ?? true
        
        if !shouldSelectItem {
            return false
        }
        
        if rootViewController.selectedIndex == index {
            self.tabBarControllerDelegate?.tabBarController(self, didSelect: viewController)
            
            if let navigationController = viewController as? UINavigationController {
                if navigationController.topViewController != navigationController.viewControllers.first {
                    navigationController.popToRootViewController(animated: true)
                }
            }
            
            return false
        }
        
        return true
    }
    
    open func tabBar(_ tabBar: MMTabBar, didSelectItemAt index: Int) {
        guard index >= 0 && index < self.rootViewController.viewControllers.count else {
            return
        }
        
        self.selectedIndex = index
        
        if let viewController = self.selectedViewController {
            self.tabBarControllerDelegate?.tabBarController(self, didSelect: viewController)
        }
    }
    
    
    open func setTabBarHidden(_ hidden: Bool, animated: Bool) {
        setBarHidden(isToolBarHidden: bottomBar.isToolBarHidden, isTabBarHidden: hidden, animated: animated)
    }
    
    open override func setToolbarHidden(_ hidden: Bool, animated: Bool) {
        setBarHidden(isToolBarHidden: hidden, isTabBarHidden: bottomBar.isTabBarHidden, animated: animated)
    }
    
    open func setBarHidden(isToolBarHidden: Bool, isTabBarHidden: Bool, animated: Bool) {
        self.view.layoutIfNeeded()
        
        bottomBar.isToolBarHidden = isToolBarHidden
        bottomBar.isTabBarHidden = isTabBarHidden
        
        if !bottomBar.isBottomBarHidden {
            bottomBar.isHidden = false
        }
        
        if !bottomBar.isToolBarHidden {
            bottomBar.toolbar.isHidden = false
        }
        
        if !bottomBar.isTabBarHidden {
            bottomBar.tabBar.isHidden = false
        }
        
        let finalFrame = finalFrameForBottomBar()
        if let transitionCoordinator = self.transitionCoordinator {
            bottomBar.isTransitioning = true
            transitionCoordinator.animate(alongsideTransition: nil) { (context) in
                self.bottomBar.isTransitioning = false
            }
        }
        UIView.animate(withDuration: animated ? 0.25 : 0, animations: {
            self.bottomBar.frame = finalFrame
            self.bottomBar.layoutIfNeeded()
        }) { (_) in
            self.adjustBottomBarsHidden()
        }
    }
    
    private func automaticallyAdjustsBottomBarHidden(by viewController: UIViewController, animated: Bool) {
        let preferredToolBarHidden = prefersToolBarHidden(in: viewController)
        let preferredTabBarHidden = prefersTabBarHidden(in: viewController)
        self.setBarHidden(isToolBarHidden: preferredToolBarHidden,
                          isTabBarHidden: preferredTabBarHidden,
                          animated: animated)
    }
    
    private func adjustBottomBarsHidden() {
        self.bottomBar.adjustsViewHiddens()
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    
    private func finalFrameForBottomBar() -> CGRect {
        let viewSize = self.view.bounds.size
        var bottomBarHeight = bottomBar.minimumContentHeight()
        
        if #available(iOS 11.0, *), !bottomBar.isBottomBarHidden {
            bottomBarHeight += self.view.safeAreaInsets.bottom
        }
        
        return CGRect(x: 0,
                      y: viewSize.height - bottomBarHeight,
                      width: viewSize.width,
                      height: bottomBarHeight)
    }
    
    open override func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        super.navigationController(navigationController, willShow: viewController, animated: animated)
        self.automaticallyAdjustsBottomBarHidden(by: viewController, animated: animated)
        if let transitionCoordinator = viewController.transitionCoordinator, let fromVC = transitionCoordinator.viewController(forKey: .from), !self.viewControllers.contains(fromVC) {
            transitionCoordinator.animate(alongsideTransition: nil) { (context) in
                if context.isCancelled {
                    self.automaticallyAdjustsBottomBarHidden(by: fromVC, animated: animated)
                }
            }
        }
    }
    
    open override func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        super.navigationController(navigationController, didShow: viewController, animated: animated)
        
        if let pendingPresentedViewController = viewController.pendingPresentedViewController {
            viewController.pendingPresentedViewController = nil
            viewController.present(pendingPresentedViewController, animated: true, completion: nil)
        }
    }
}
