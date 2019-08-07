//
//  MMTabBarRootViewController.swift
//  MyMediaPlayer
//
//  Created by wuweixin on 2019/7/18.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import MTDNavigationView

class MMTabBarRootViewController: UIViewController, MMTabBarDelegate, MTDViewControllerNaked {
    weak var mmTabBarController: MMTabBarController?
    
    var viewControllers: [UIViewController] = [] {
        didSet {
            oldValue.forEach { (viewController) in
                viewController.willMove(toParent: nil)
                viewController.view.removeFromSuperview()
                viewController.removeFromParent()
            }
            
            var tabBarItems: [MMTabBarItem] = []
            viewControllers.forEach { (viewController) in
                let tabBarItem = MMTabBarItem()
                tabBarItem.title = viewController.title
                tabBarItems.append(tabBarItem)
            }
            mmTabBarController?.tabBar.items = tabBarItems
        }
    }
    
    var selectedViewController: UIViewController? {
        return viewController(at: selectedIndex)
    }
    
    /// The index of the view controller associated with the currently selected tab item.
    var selectedIndex: Int = 0 {
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
            
            mmTabBarController?.tabBar.selectedIndex = self.selectedIndex
            self.view.setNeedsLayout()
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    lazy var contentView: UIView = {
        let view = UIView()
        let contentView = UIView()
        contentView.backgroundColor = UIColor.clear
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return view
    }()
    
    
    convenience init(with tabBarController: MMTabBarController) {
        self.init()
        self.mmTabBarController = tabBarController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.frame = self.view.bounds
        self.view.addSubview(contentView)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.selectedViewController?.preferredStatusBarStyle ?? super.preferredStatusBarStyle
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return self.selectedViewController?.preferredStatusBarUpdateAnimation ?? super.preferredStatusBarUpdateAnimation
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        var mask = UIInterfaceOrientationMask.all
        
        viewControllers.forEach { (vc) in
            let supportedOrientations = vc.supportedInterfaceOrientations
            if mask.rawValue > supportedOrientations.rawValue {
                mask = supportedOrientations
            }
        }
        
        return mask
    }
    
    
    func viewController(at index: Int) -> UIViewController? {
        guard index >= 0 && index < viewControllers.count else {
            return nil
        }
        
        return viewControllers[index]
    }
}

extension MMTabBarRootViewController: MMToolBarDisplayble, MMTabBarDisplayble {
    var preferredToolBarHidden: Bool {
        return false
    }
    
    var preferredTabBarHidden: Bool {
        return false
    }
}
