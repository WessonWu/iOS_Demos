//
//  MTDWrapperController.swift
//  MTDNavigationViewDemo
//
//  Created by wuweixin on 2019/8/1.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit

open class MTDWrapperController: UIViewController, MTDNavigationViewDelegate {
    public private(set) var contentViewController: UIViewController!
    
    var observations: [NSKeyValueObservation] = []
    
    public convenience init(contentViewController: UIViewController) {
        self.init()
        self.contentViewController = contentViewController
    }
    
    open override func loadView() {
        let wrapperView = ViewControllerWrapperView(frame: UIScreen.main.bounds)
        wrapperView.contentViewController = contentViewController
        self.view = wrapperView
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let vc = self.contentViewController else {
            return
        }
        
        let mtd_vc = vc.mtd
        let navigationView = mtd_vc.navigationView
        self.view.addSubview(navigationView)
        self.addChild(vc)
        let contentView: UIView = vc.view
        contentView.frame = self.view.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.insertSubview(contentView, at: 0)
        vc.didMove(toParent: self)
        
        navigationView.titleLabel.text = contentViewController.title
        let ob1 = contentViewController.observe(\.title) { (vc, _) in
            navigationView.titleLabel.text = vc.title
        }
        observations = [ob1]
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        automaticallyAdjustsInsetsIfNeeded()
    }
    
    func automaticallyAdjustsInsetsIfNeeded() {
        let mtd_vc = contentViewController.mtd
        let navigationView = mtd_vc.navigationView
        let extended = contentViewController.extendedLayoutIncludesOpaqueBars && !contentViewController.edgesForExtendedLayout.contains(.top)
        let shouldAdjustsScrollInsets = !navigationView.isNavigationViewHidden && (navigationView.isTranslucent || extended)
        if #available(iOS 11.0, *) {
            if shouldAdjustsScrollInsets {
                contentViewController.adjustedSafeAreaInsetTop = navigationView.frame.height - self.view.safeAreaInsets.top
            } else {
                contentViewController.adjustedSafeAreaInsetTop = 0
            }
        } else {
            if shouldAdjustsScrollInsets && self.automaticallyAdjustsScrollViewInsets {
                contentViewController.adjustsScrollViewInsets(top: navigationView.frame.height)
            } else {
                contentViewController.adjustsScrollViewInsets(top: 0)
            }
        }
    }
    
    open func setNavigationViewHidden(_ hidden: Bool, animated: Bool) {
        guard let view = self.view as? ViewControllerWrapperView else {
            return
        }
        view.setNavigationViewHidden(hidden, animated: animated)
    }
    
    open override var edgesForExtendedLayout: UIRectEdge {
        get {
            var edges = contentViewController.edgesForExtendedLayout
            if #available(iOS 11.0, *) {
                
            } else {
                // 避免UIScrollView的contentInset多出20的高度
                edges.remove(.top)
            }
            return edges
        }
        set {
            contentViewController.edgesForExtendedLayout = newValue
        }
    }
    
    open override var extendedLayoutIncludesOpaqueBars: Bool {
        get {
            return contentViewController.extendedLayoutIncludesOpaqueBars
        }
        set {
            contentViewController.extendedLayoutIncludesOpaqueBars = newValue
        }
    }
    
    open override var automaticallyAdjustsScrollViewInsets: Bool {
        get {
            return contentViewController.automaticallyAdjustsScrollViewInsets
        }
        set {
            contentViewController.automaticallyAdjustsScrollViewInsets = newValue
        }
    }
    
    @available(iOS 11.0, *)
    open override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        self.automaticallyAdjustsInsetsIfNeeded()
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
    
    public func performBackAction(in navigationView: MTDNavigationView) {
        self.dismiss(animated: true, completion: nil)
    }
    
    deinit {
        observations.forEach { $0.invalidate() }
        observations = []
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


