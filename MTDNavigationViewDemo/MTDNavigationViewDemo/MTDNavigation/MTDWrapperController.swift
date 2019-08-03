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
    
    var isNavigationViewHidden: Bool = true
    
    private var reservedSpaceContraints: [NSLayoutConstraint] = []
    private var noReservedSpaceContraints: [NSLayoutConstraint] = []
    
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
        self.view.insertSubview(contentView, at: 0)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        let reservedSpaceContraint = contentView.topAnchor.constraint(equalTo: navigationView.bottomAnchor)
        let noReservedSpaceContraint = contentView.topAnchor.constraint(equalTo: self.view.topAnchor)
        self.reservedSpaceContraints = [reservedSpaceContraint]
        self.noReservedSpaceContraints = [noReservedSpaceContraint]
        contentView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.view.setNeedsUpdateConstraints()
        self.view.updateConstraintsIfNeeded()
        vc.didMove(toParent: self)
    }
    
    open override func updateViewConstraints() {
        let mtd_vc = contentViewController.mtd
        let navigationView = mtd_vc.navigationView
        if navigationView.isTranslucent {
            NSLayoutConstraint.deactivate(self.reservedSpaceContraints)
            NSLayoutConstraint.activate(self.noReservedSpaceContraints)
        } else {
            NSLayoutConstraint.deactivate(self.noReservedSpaceContraints)
            NSLayoutConstraint.activate(self.reservedSpaceContraints)
        }
        
        if isNavigationViewHidden {
            
        }
        super.updateViewConstraints()
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


