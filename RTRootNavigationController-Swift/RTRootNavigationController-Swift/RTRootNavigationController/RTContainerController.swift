//
//  RTContainerController.swift
//  RTRootNavigationController-Swift
//
//  Created by wuweixin on 2019/7/22.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit

open class RTContainerController: UIViewController {
    
    var contentViewController: UIViewController!
    var containerNavigationController: UINavigationController?
    
    init(contentViewController: UIViewController,
         navigationBarClass: AnyClass? = nil,
         withPlaceholderController yesOrNo: Bool = false,
         backBarButtonItem: UIBarButtonItem? = nil,
         backTitle: String? = nil) {
        self.contentViewController = contentViewController
        let containerNavigationController = UINavigationController(navigationBarClass: navigationBarClass,
                                                                   toolbarClass: nil)
        self.containerNavigationController = containerNavigationController
        if yesOrNo {
            let vc = UIViewController()
            vc.title = backTitle
            vc.navigationItem.backBarButtonItem = backBarButtonItem
            containerNavigationController.viewControllers = [vc, contentViewController]
        } else {
            containerNavigationController.viewControllers = [contentViewController]
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    init(contentViewControllerNoWrapping contentViewController: UIViewController) {
        self.contentViewController = contentViewController
        super.init(nibName: nil, bundle: nil)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        if let containerNavigationController = self.containerNavigationController {
            self.addChild(containerNavigationController)
            let containerView: UIView = containerNavigationController.view
            containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            containerView.frame = self.view.bounds
            self.view.addSubview(containerView)
            containerNavigationController.didMove(toParent: self)
        } else {
            self.addChild(contentViewController)
            let containerView: UIView = contentViewController.view
            containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            containerView.frame = self.view.bounds
            self.view.addSubview(containerView)
            contentViewController.didMove(toParent: self)
        }
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
