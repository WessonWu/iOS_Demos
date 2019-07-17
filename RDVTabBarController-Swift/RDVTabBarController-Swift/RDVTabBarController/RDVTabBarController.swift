//
//  RDVTabBarController.swift
//  RDVTabBarController-Swift
//
//  Created by wuweixin on 2019/7/17.
//  Copyright © 2019 cn.wessonwu. All rights
import UIKit


public protocol RDVTabBarControllerDelegate: AnyObject {
    /// Asks the delegate whether the specified view controller should be made active.
    func tabBarController(_ tabBarController: RDVTabBarController, shouldSelect viewController: UIViewController) -> Bool
    
    /// Tells the delegate that the user selected an item in the tab bar.
    func tabBarController(_ tabBarController: RDVTabBarController, didSelect viewController: UIViewController)
    
    /// Tells the delegate that the user tap on the selected item in the tab bar.
    func tabBarController(_ tabBarController: RDVTabBarController, didSelectItemAt index: Int)
}

extension RDVTabBarControllerDelegate {
    func tabBarController(_ tabBarController: RDVTabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true
    }
    func tabBarController(_ tabBarController: RDVTabBarController, didSelect viewController: UIViewController) {}
    func tabBarController(_ tabBarController: RDVTabBarController, didSelectItemAt index: Int) {}
}

public class RDVTabBarController: UIViewController, RDVTabBarDelegate {
    /// The tab bar controller’s delegate object.
    public weak var delegate: RDVTabBarControllerDelegate?
    /// An array of the root view controllers displayed by the tab bar interface.
    public var viewControllers: [UIViewController] = [] {
        didSet {
            oldValue.forEach { (viewController) in
                viewController.willMove(toParent: nil)
                viewController.view.removeFromSuperview()
                viewController.removeFromParent()
                viewController.rdv_tabBarController = nil
            }
            
            var tabBarItems: [RDVTabBarItem] = []
            viewControllers.forEach { (viewController) in
                let tabBarItem = RDVTabBarItem()
                tabBarItem.title = viewController.title
                tabBarItems.append(tabBarItem)
                viewController.rdv_tabBarController = self
            }
            
            self.tabBar.items = tabBarItems
        }
    }
    /// The tab bar view associated with this controller. (read-only)
    public private(set) lazy var tabBar: RDVTabBar = { [unowned self] in
        let tabBar = RDVTabBar()
        tabBar.backgroundColor = UIColor.clear
        tabBar.autoresizingMask = [.flexibleWidth,
                                   .flexibleTopMargin,
                                   .flexibleBottomMargin]
        tabBar.delegate = self
        return tabBar
    }()
    /// The view controller associated with the currently selected tab item.
    public var selectedViewController: UIViewController? {
        return viewController(at: selectedIndex)
    }
    /// The index of the view controller associated with the currently selected tab item.
    public var selectedIndex: Int = 0 {
        didSet {
            guard self.selectedIndex != oldValue || self.selectedViewController?.parent == nil else {
                return
            }
            
            if let selectedVC = viewController(at: oldValue) {
                selectedVC.willMove(toParent: nil)
                selectedVC.view.removeFromSuperview()
                selectedVC.removeFromParent()
            }
            
            if let selectedVC = self.selectedViewController {
                self.addChild(selectedVC)
                selectedVC.view.frame = contentView.bounds
                selectedVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                self.contentView.addSubview(selectedVC.view)
                selectedVC.didMove(toParent: self)
            }
            
            self.tabBar.selectedIndex = self.selectedIndex
            self.view.setNeedsLayout()
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    /// A Boolean value that determines whether the tab bar is hidden.
    public private(set) var isTabBarHidden: Bool = false
    
    private lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.backgroundColor = UIColor.white
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return contentView
    }()

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.contentView)
        self.view.addSubview(self.tabBar)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let index = self.selectedIndex
        self.selectedIndex = index
    }
    
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let viewSize = self.view.bounds.size
        var tabBarStartingY = viewSize.height
        var contentViewHeight = viewSize.height
        var tabBarHeight = self.tabBar.frame.height
        
        if tabBarHeight <= 0 {
            if #available(iOS 11.0, *) {
                let safeAreaBottom = self.view.safeAreaInsets.bottom
                tabBarHeight = 49 + safeAreaBottom
            } else {
                tabBarHeight = 49
            }
        } else if #available(iOS 11.0, *) {
            let safeAreaBottom = self.view.safeAreaInsets.bottom
            tabBarHeight = 49 + safeAreaBottom
        }
        
        if !self.isTabBarHidden {
            tabBarStartingY = viewSize.height - tabBarHeight
            if !self.tabBar.isTranslucent {
                contentViewHeight -= self.tabBar.minimumContentHeight
            }
        }
        
        
        self.tabBar.frame = CGRect(x: 0, y: tabBarStartingY, width: viewSize.width, height: tabBarHeight)
        self.contentView.frame = CGRect(x: 0, y: 0, width: viewSize.width, height: contentViewHeight)
    }
    
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.selectedViewController?.preferredStatusBarStyle ?? super.preferredStatusBarStyle
    }
    
    public override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return self.selectedViewController?.preferredStatusBarUpdateAnimation ?? super.preferredStatusBarUpdateAnimation
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        var mask = UIInterfaceOrientationMask.all
        
        viewControllers.forEach { (vc) in
            let supportedOrientations = vc.supportedInterfaceOrientations
            if mask.rawValue > supportedOrientations.rawValue {
                mask = supportedOrientations
            }
        }
        
        return mask
    }
    
    
    
    /// Changes the visibility of the tab bar.
    public func setTabBarHidden(_ hidden: Bool, animated: Bool = false) {
        // make sure any pending layout is done, to prevent spurious animations
        self.view.layoutIfNeeded()
        
        self.isTabBarHidden = hidden
        
        self.view.setNeedsLayout()
        
        if !isTabBarHidden {
            self.tabBar.isHidden = false
        }
        
        UIView.animate(withDuration: animated ? 0.24 : 0, animations: {
            self.view.layoutIfNeeded()
        }) { (finished) in
            self.tabBar.isHidden = self.isTabBarHidden
        }
    }
    
    
    func viewController(at index: Int) -> UIViewController? {
        guard index >= 0 && index < viewControllers.count else {
            return nil
        }
        
        return viewControllers[index]
    }
    
    func index(for viewController: UIViewController?) -> Int? {
        guard let vc = viewController else {
            return nil
        }
        
        var searchedController = vc
        while let parentVC = searchedController.parent, parentVC != self {
            searchedController = parentVC
        }
        
        return viewControllers.firstIndex(where: { searchedController.isEqual($0) })
    }
    
    
    
    // MARK: - RDVTabBarDelegate
    public func tabBar(_ tabBar: RDVTabBar, shouldSelectItemAt index: Int) -> Bool {
        guard let viewController = self.viewController(at: index) else {
            return false
        }
        let shouldSelectItem = self.delegate?.tabBarController(self, shouldSelect: viewController) ?? true
        
        if !shouldSelectItem {
            return false
        }
        
        if self.selectedIndex == index {
            self.delegate?.tabBarController(self, didSelect: viewController)
            
            if let navigationController = viewController as? UINavigationController {
                if navigationController.topViewController != navigationController.viewControllers.first {
                    navigationController.popToRootViewController(animated: true)
                }
            }
            
            return false
        }
        
        return true
    }
    
    public func tabBar(_ tabBar: RDVTabBar, didSelectItemAt index: Int) {
        guard index >= 0 && index < self.viewControllers.count else {
            return
        }
        
        self.selectedIndex = index
        
        if let viewController = self.selectedViewController {
            self.delegate?.tabBarController(self, didSelect: viewController)
        }
    }
}
