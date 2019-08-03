//
//  MTDWrapperController.swift
//  MTDNavigationViewDemo
//
//  Created by wuweixin on 2019/8/1.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit

open class MTDWrapperController: UIViewController {
    public private(set) var contentViewController: UIViewController!
    
    public convenience init(contentViewController: UIViewController) {
        self.init()
        self.contentViewController = contentViewController
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let vc = self.contentViewController else {
            return
        }
        
        let mtd_vc = vc.mtd
        let navigationView = mtd_vc.navigationView
        navigationView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(navigationView)
        navigationView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        navigationView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        navigationView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.addChild(vc)
        let contentView: UIView = vc.view
        contentView.frame = self.view.bounds
        self.view.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.topAnchor.constraint(equalTo: navigationView.bottomAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        vc.didMove(toParent: self)
    }
    
    
    open override func becomeFirstResponder() -> Bool {
        return contentViewController.becomeFirstResponder()
    }
    
    open override var canBecomeFirstResponder: Bool {
        return contentViewController.canBecomeFirstResponder
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return contentViewController.preferredStatusBarStyle
    }
    
    open override var prefersStatusBarHidden: Bool {
        return contentViewController.prefersStatusBarHidden
    }
    
    open override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return contentViewController.preferredStatusBarUpdateAnimation
    }
    
    @available(iOS 11.0, *)
    open override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return contentViewController.preferredScreenEdgesDeferringSystemGestures
    }
    
    @available(iOS 11.0, *)
    open override var childForScreenEdgesDeferringSystemGestures: UIViewController? {
        return contentViewController.childForScreenEdgesDeferringSystemGestures
    }
    
    @available(iOS 11.0, *)
    open override var prefersHomeIndicatorAutoHidden: Bool {
        return contentViewController.prefersHomeIndicatorAutoHidden
    }
    
    @available(iOS 11.0, *)
    open override var childForHomeIndicatorAutoHidden: UIViewController? {
        return contentViewController
    }
    
    open override var shouldAutorotate: Bool {
        return contentViewController.shouldAutorotate
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return contentViewController.supportedInterfaceOrientations
    }
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return contentViewController.preferredInterfaceOrientationForPresentation
    }
    
    open override var hidesBottomBarWhenPushed: Bool {
        get {
            return contentViewController.hidesBottomBarWhenPushed
        }
        set {
            contentViewController.hidesBottomBarWhenPushed = newValue
        }
    }
    
    open override var title: String? {
        get {
            return contentViewController.title
        }
        set {
            contentViewController.title = newValue
        }
    }
    
    open override var tabBarItem: UITabBarItem! {
        get {
            return contentViewController.tabBarItem
        }
        set {
            super.tabBarItem = newValue
        }
    }
    
    open override var debugDescription: String {
        return String(format: "<%@: %p contentViewController: %@>", NSStringFromClass(type(of: self)), self, self.contentViewController)
    }
}


@inline(__always) func MTDSafeWrapViewController(_ viewController: UIViewController) -> UIViewController {
    if let vc = viewController as? MTDWrapperController {
        return vc
    }
    return MTDWrapperController(contentViewController: viewController)
}


@inline(__always) func MTDSafeUnwrapViewController(_ viewController: UIViewController) -> UIViewController {
    if let vc = viewController as? MTDWrapperController {
        return vc.contentViewController
    }
    return viewController
}


