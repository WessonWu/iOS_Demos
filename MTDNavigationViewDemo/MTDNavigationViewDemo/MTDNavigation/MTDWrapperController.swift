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
        
        self.addChild(self.contentViewController)
        let contentView: UIView = contentViewController.view
        contentView.frame = self.view.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(contentView)
        contentViewController.didMove(toParent: self)
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


