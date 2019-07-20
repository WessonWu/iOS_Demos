//
//  MMTabBarController.swift
//  MyMediaPlayer
//
//  Created by wuweixin on 2019/7/18.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit

public protocol MMTabBarControllerDelegate: AnyObject {
    /// Asks the delegate whether the specified view controller should be made active.
    func tabBarController(_ tabBarController: MMTabBarController, shouldSelect viewController: UIViewController) -> Bool
    
    /// Tells the delegate that the user selected an item in the tab bar.
    func tabBarController(_ tabBarController: MMTabBarController, didSelect viewController: UIViewController)
    
    /// Tells the delegate that the user tap on the selected item in the tab bar.
    func tabBarController(_ tabBarController: MMTabBarController, didSelectItemAt index: Int)
}

extension MMTabBarControllerDelegate {
    func tabBarController(_ tabBarController: MMTabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true
    }
    func tabBarController(_ tabBarController: MMTabBarController, didSelect viewController: UIViewController) {}
    func tabBarController(_ tabBarController: MMTabBarController, didSelectItemAt index: Int) {}
}

public class MMTabBarController: MMNavigationController, MMTabBarDelegate {
    
    public weak var tabBarControllerDelegate: MMTabBarControllerDelegate?
    
    public var tabBarViewControllers: [UIViewController] {
        get {
            return rootViewController.viewControllers
        }
        set {
            rootViewController.viewControllers = newValue
        }
    }
    
    public var selectedIndex: Int {
        get {
            return rootViewController.selectedIndex
        }
        set {
            rootViewController.selectedIndex = newValue
        }
    }
    
    public var selectedViewController: UIViewController? {
        return rootViewController.selectedViewController
    }
    
    public var tabBar: MMTabBar {
        return bottomBar.tabBar
    }
    
    public private(set) lazy var bottomBar: MMBottomBar = {
        let bottomBar = MMBottomBar()
        bottomBar.autoresizingMask = [.flexibleWidth,
                                   .flexibleTopMargin,
                                   .flexibleBottomMargin]
        bottomBar.tabBar.delegate = self
        return bottomBar
    }()
    
    
    lazy var rootViewController: MMTabBarRootViewController = MMTabBarRootViewController(with: self)
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return topViewController?.supportedInterfaceOrientations ?? super.supportedInterfaceOrientations
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.viewControllers = [rootViewController]
        self.view.addSubview(bottomBar)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let index = self.selectedIndex
        self.selectedIndex = index
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bottomBar.frame = finalFrameForBottomBar()
    }
    
    public func tabBar(_ tabBar: MMTabBar, shouldSelectItemAt index: Int) -> Bool {
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
    
    public func tabBar(_ tabBar: MMTabBar, didSelectItemAt index: Int) {
        guard index >= 0 && index < self.rootViewController.viewControllers.count else {
            return
        }
        
        self.selectedIndex = index
        
        if let viewController = self.selectedViewController {
            self.tabBarControllerDelegate?.tabBarController(self, didSelect: viewController)
        }
    }
    
    
    public func setTabBarHidden(_ hidden: Bool, animated: Bool) {
        setBarHidden(isToolBarHidden: bottomBar.isToolBarHidden, isTabBarHidden: hidden, animated: animated)
    }
    
    public override func setToolbarHidden(_ hidden: Bool, animated: Bool) {
        setBarHidden(isToolBarHidden: hidden, isTabBarHidden: bottomBar.isTabBarHidden, animated: animated)
    }
    
    public func setBarHidden(isToolBarHidden: Bool, isTabBarHidden: Bool, animated: Bool) {
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
        let preferredToolBarHidden = (viewController as? MMToolBarDisplayble)?.preferredToolBarHidden ?? true
        let preferredTabBarHidden = (viewController as? MMTabBarDisplayble)?.preferredTabBarHidden ?? true
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
}

extension MMTabBarController {
    public override func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
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
}
