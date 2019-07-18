//
//  MMTabBarController.swift
//  MyMediaPlayer
//
//  Created by wuweixin on 2019/7/18.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit

public protocol MMBottomBarDisplayable {
    var shouldSongViewHidden: Bool { get }
    var shouldTabBarHidden: Bool { get }
}

extension MMBottomBarDisplayable {
    var shouldSongViewHidden: Bool {
        return true
    }
    var shouldTabBarHidden: Bool {
        return true
    }
}

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

public class MMTabBarController: UINavigationController, MMTabBarDelegate {
    
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
        self.navigationBar.isHidden = true
        self.interactivePopGestureRecognizer?.delegate = self
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
    
    public override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
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
    
    public func setBottomBarHidden(isSongViewHidden: Bool, isTabBarHidden: Bool, animated: Bool) {
        self.view.layoutIfNeeded()
        
        bottomBar.isSongViewHidden = isSongViewHidden
        bottomBar.isTabBarHidden = isTabBarHidden
        
        if !bottomBar.isBottomBarHidden {
            bottomBar.isHidden = false
        }
        
        if !bottomBar.isSongViewHidden {
            bottomBar.songView.isHidden = false
        }
        
        if !bottomBar.isTabBarHidden {
            bottomBar.tabBar.isHidden = false
        }
        
        let finalFrame = finalFrameForBottomBar()
        UIView.animate(withDuration: animated ? 0.24 : 0, animations: {
            self.bottomBar.frame = finalFrame
        }) { (_) in
            self.bottomBar.isHidden = self.bottomBar.isBottomBarHidden
            self.bottomBar.songView.isHidden = self.bottomBar.isSongViewHidden
            self.bottomBar.tabBar.isHidden = self.bottomBar.isTabBarHidden
        }
    }
    
    
    public func setBottomBarHidden(fromVC: UIViewController, toVC: UIViewController, alongside transitionCoordinator: UIViewControllerTransitionCoordinator?) {
        if let coordinator = transitionCoordinator {
        } else {
            let hiddens = toVC.bottomBarHiddens()
        }
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

extension MMTabBarController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}


fileprivate typealias BottomBarHiddens = (isSongViewHidden: Bool, isTabBarHidden: Bool)
fileprivate extension UIViewController {
    func bottomBarHiddens() -> BottomBarHiddens {
        if let displayable = self as? MMBottomBarDisplayable {
            return (displayable.shouldSongViewHidden, displayable.shouldTabBarHidden)
        }
        return (true, true)
    }
}
