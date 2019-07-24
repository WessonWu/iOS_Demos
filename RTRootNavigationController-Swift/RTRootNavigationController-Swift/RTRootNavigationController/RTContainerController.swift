//
//  RTContainerController.swift
//  RTRootNavigationController-Swift
//
//  Created by wuweixin on 2019/7/22.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit

class RTContainerController: UIViewController {
    
    var contentViewController: UIViewController!
    var containerNavigationController: UINavigationController!
    
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
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.addChild(containerNavigationController)
        let containerView: UIView = containerNavigationController.view
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.frame = self.view.bounds
        self.view.addSubview(containerView)
        containerNavigationController.didMove(toParent: self)
    }
    
    
    override func becomeFirstResponder() -> Bool {
        return contentViewController.becomeFirstResponder()
    }
    
    override var canBecomeFirstResponder: Bool {
        return contentViewController.canBecomeFirstResponder
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return contentViewController.preferredStatusBarStyle
    }
    
    override var prefersStatusBarHidden: Bool {
        return contentViewController.prefersStatusBarHidden
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return contentViewController.preferredStatusBarUpdateAnimation
    }
    
    @available(iOS 11.0, *)
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return contentViewController.preferredScreenEdgesDeferringSystemGestures
    }

    @available(iOS 11.0, *)
    override var childForScreenEdgesDeferringSystemGestures: UIViewController? {
        return contentViewController.childForScreenEdgesDeferringSystemGestures
    }
    
    @available(iOS 11.0, *)
    override var prefersHomeIndicatorAutoHidden: Bool {
        return contentViewController.prefersHomeIndicatorAutoHidden
    }
    
    @available(iOS 11.0, *)
    override var childForHomeIndicatorAutoHidden: UIViewController? {
        return contentViewController
    }
    
    override var shouldAutorotate: Bool {
        return contentViewController.shouldAutorotate
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return contentViewController.supportedInterfaceOrientations
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return contentViewController.preferredInterfaceOrientationForPresentation
    }
    
    override var hidesBottomBarWhenPushed: Bool {
        get {
            return contentViewController.hidesBottomBarWhenPushed
        }
        set {
            contentViewController.hidesBottomBarWhenPushed = newValue
        }
    }
    
    override var title: String? {
        get {
            return contentViewController.title
        }
        set {
            contentViewController.title = newValue
        }
    }
    
    override var tabBarItem: UITabBarItem! {
        get {
            return contentViewController.tabBarItem
        }
        set {
            contentViewController.tabBarItem = newValue
        }
    }
    
    override var debugDescription: String {
        return String(format: "<%@: %p contentViewController: %@>", NSStringFromClass(type(of: self)), self, self.contentViewController)
    }
}
