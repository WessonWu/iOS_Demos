//
//  RTRootNavigationController.swift
//  RTRootNavigationController-Swift
//
//  Created by wuweixin on 2019/7/22.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit

@IBDesignable
open class RTRootNavigationController: UINavigationController {
    public typealias Completion = (Bool) -> Void
    /*!
     *  @brief use system original back bar item or custom back bar item returned by
     *  @c -(UIBarButtonItem*)customBackItemWithTarget:action: , default is NO
     *  @warning Set this to @b YES will @b INCREASE memory usage!
     */
    open var useSystemBackBarButtonItem: Bool = false
    
    /// Weather each individual navigation bar uses the visual style of root navigation bar. Default is @b NO
    open var transferNavigationBarAttributes: Bool = false
    
    weak var rt_delegate: UINavigationControllerDelegate?
    
    
    var animationBlock: Completion?
    
    /**
     *  Init with a root view controller without wrapping into a navigation controller
     *
     *  @param rootViewController The root view controller
     *
     *  @return new instance
     */
    public convenience init(rootViewControllerNoWrapping rootViewController: UIViewController) {
        self.init(rootViewController: RTContainerController(contentViewController: rootViewController))
    }
    
    public override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        commonInit()
    }
    
    public override init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        self.viewControllers = super.viewControllers
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.delegate = self
        super.setNavigationBarHidden(true, animated: false)
    }
    
    open override func forUnwindSegueAction(_ action: Selector, from fromViewController: UIViewController, withSender sender: Any?) -> UIViewController? {
        var viewController = super.forUnwindSegueAction(action,
                                                        from: fromViewController,
                                                        withSender: sender)
        
        if viewController == nil {
            if let index = self.viewControllers.firstIndex(of: fromViewController) {
                for idx in (index - 1) ... 0 {
                    viewController = viewControllers[idx].forUnwindSegueAction(action,
                                                                               from: fromViewController,
                                                                               withSender: sender)
                    if viewController != nil {
                        break
                    }
                }
            }
        }
        
        return viewController
        
    }
    
    open override func setNavigationBarHidden(_ hidden: Bool, animated: Bool) {
        // Override to protect
    }
    
    open override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        let wrapped: UIViewController
        if let lastViewController = self.viewControllers.last {
            let currentLast = RTSafeUnwrapViewController(lastViewController)
            wrapped = RTSafeWrapViewController(viewController,
                                               navigationBarClass: viewController.rt.navigationBarClass,
                                               withPlaceholder: self.useSystemBackBarButtonItem,
                                               backItem: currentLast.navigationItem.backBarButtonItem,
                                               backTitle: currentLast.navigationItem.title ?? currentLast.title)
        } else {
            wrapped = RTSafeWrapViewController(viewController,
                                               navigationBarClass: viewController.rt.navigationBarClass)
        }
        
        super.pushViewController(wrapped, animated: animated)
    }
    
    open override func popViewController(animated: Bool) -> UIViewController? {
        return super.popViewController(animated: animated).map {
            RTSafeUnwrapViewController($0)
        }
    }
    
    open override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        return super.popToRootViewController(animated: animated).map({ (viewControllers) -> [UIViewController] in
            viewControllers.map { RTSafeUnwrapViewController($0) }
        })
    }
    
    open override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        guard let controllerToPop = self.viewControllers.first(where: { RTSafeUnwrapViewController($0) == viewController }) else {
            return nil
        }
        
        return super.popToViewController(controllerToPop, animated: animated).map({ (viewControllers) -> [UIViewController] in
            viewControllers.map { RTSafeUnwrapViewController($0) }
        })
    }
    
    open override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        var wraps: [UIViewController] = []
        for (index, vc) in viewControllers.enumerated() {
            if self.useSystemBackBarButtonItem && index > 0 {
                let prev = self.viewControllers[index - 1]
                wraps.append(RTSafeWrapViewController(vc,
                                                      navigationBarClass: vc.rt.navigationBarClass,
                                                      withPlaceholder: self.useSystemBackBarButtonItem,
                                                      backItem: prev.navigationItem.backBarButtonItem,
                                                      backTitle: prev.title))
            } else {
                wraps.append(RTSafeWrapViewController(vc, navigationBarClass: vc.rt.navigationBarClass))
            }
        }
        super.setViewControllers(wraps, animated: animated)
    }
    
    open override var shouldAutorotate: Bool {
        return topViewController?.shouldAutorotate ?? super.shouldAutorotate
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return topViewController?.supportedInterfaceOrientations ?? super.supportedInterfaceOrientations
    }
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return topViewController?.preferredInterfaceOrientationForPresentation ?? super.preferredInterfaceOrientationForPresentation
    }
    
    
    open override func responds(to aSelector: Selector!) -> Bool {
        if super.responds(to: aSelector) {
            return true
        }
        
        return rt_delegate?.responds(to: aSelector) ?? false
    }
    
    open override func forwardingTarget(for aSelector: Selector!) -> Any? {
        return rt_delegate
    }
    
    
    
    open func removeViewController(_ viewController: UIViewController, animated: Bool = false) {
        var viewControllers = self.viewControllers
        guard let index = viewControllers.firstIndex(where: { RTSafeUnwrapViewController($0) == viewController }) else {
            return
        }
        
        viewControllers.remove(at: index)
        super.setViewControllers(viewControllers, animated: animated)
    }
    
    
    
    open func pushViewController(_ viewController: UIViewController, animated: Bool, completion: Completion?) {
        if let animationBlock = self.animationBlock {
            animationBlock(false)
        }
        self.animationBlock = completion
        self.pushViewController(viewController, animated: animated)
    }
    
    open func popViewController(animated: Bool, completion: Completion?) -> UIViewController? {
        if let animationBlock = self.animationBlock {
            animationBlock(false)
        }
        self.animationBlock = completion
        
        let vc = self.popViewController(animated: animated)
        if vc == nil {
            if let animationBlock = self.animationBlock {
                animationBlock(true)
                self.animationBlock = nil
            }
        }
        return vc
    }
    
    open func popToViewController(_ viewController: UIViewController, animated: Bool, completion: Completion?) -> [UIViewController]? {
        if let animationBlock = self.animationBlock {
            animationBlock(false)
        }
        self.animationBlock = completion
        
        let viewControllers = self.popToViewController(viewController, animated: animated)
        
        let count = viewControllers?.count ?? 0
        if count == 0 {
            if let animationBlock = self.animationBlock {
                animationBlock(true)
                self.animationBlock = nil
            }
        }
        
        return viewControllers
    }
    
    
    open func popToRootViewController(animated: Bool, completion: Completion?) -> [UIViewController]? {
        if let animationBlock = self.animationBlock {
            animationBlock(false)
        }
        self.animationBlock = completion
        
        let viewControllers = self.popToRootViewController(animated: animated)
        
        let count = viewControllers?.count ?? 0
        if count == 0 {
            if let animationBlock = self.animationBlock {
                animationBlock(true)
                self.animationBlock = nil
            }
        }
        
        return viewControllers
    }
    
}

extension RTRootNavigationController: UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let isRootVC = viewController.isEqual(self.viewControllers.first)
        var unwrapped = RTSafeUnwrapViewController(viewController)
        if !isRootVC && unwrapped.isViewLoaded {
            let hasSetLeftItem = viewController.navigationItem.leftBarButtonItem != nil
            
        }
    }
}
