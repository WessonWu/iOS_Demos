//
//  MTDNavigationController.swift
//  MTDNavigationViewDemo
//
//  Created by wuweixin on 2019/8/1.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit

@IBDesignable
open class MTDNavigationController: UINavigationController, MTDNavigationViewDelegate {
    public typealias Completion = (Bool) -> Void
    
    open override var delegate: UINavigationControllerDelegate? {
        get {
            return super.delegate
        }
        set {
            self.mtd_delegate = newValue
        }
    }
    
    weak var mtd_delegate: UINavigationControllerDelegate?
    
    var completionHandler: Completion?
    
    // MARK: - Override
    
    public override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        commonInit()
    }
    
    public override init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
        commonInit()
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        // do nothing
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        self.viewControllers = super.viewControllers
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.interactivePopGestureRecognizer?.delaysTouchesBegan = true
        self.interactivePopGestureRecognizer?.delegate = self
        self.interactivePopGestureRecognizer?.isEnabled = true
        
        super.delegate = self
        super.navigationBar.isTranslucent = false
        super.setNavigationBarHidden(true, animated: false)
    }
    
    open override func setNavigationBarHidden(_ hidden: Bool, animated: Bool) {
        // Override to protect
    }
    
    open override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        let wrapped: UIViewController = MTDSafeWrapViewController(viewController)
        super.pushViewController(wrapped, animated: animated)
    }
    
    @discardableResult
    open override func popViewController(animated: Bool) -> UIViewController? {
        return super.popViewController(animated: animated).map {
            MTDSafeUnwrapViewController($0)
        }
    }
    
    @discardableResult
    open override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        return super.popToRootViewController(animated: animated).map({ (viewControllers) -> [UIViewController] in
            viewControllers.map { MTDSafeUnwrapViewController($0) }
        })
    }
    
    @discardableResult
    open override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        guard let controllerToPop = self.viewControllers.first(where: { MTDSafeUnwrapViewController($0) == viewController }) else {
            return nil
        }
        
        return super.popToViewController(controllerToPop, animated: animated).map({ (viewControllers) -> [UIViewController] in
            viewControllers.map { MTDSafeUnwrapViewController($0) }
        })
    }
    
    open override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        let wraps = viewControllers.map { MTDSafeWrapViewController($0) }
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
        
        return mtd_delegate?.responds(to: aSelector) ?? false
    }
    
    open override func forwardingTarget(for aSelector: Selector!) -> Any? {
        return mtd_delegate
    }
    
    // MARK: - Custom Public Method (Push & Pop)
    
    
    /// Remove a content view controller from the stack
    ///
    /// - Parameters:
    ///   - viewController: the content view controller
    ///   - animated: use animation or not
    open func removeViewController(_ viewController: UIViewController, animated: Bool = false) {
        var viewControllers = self.viewControllers
        guard let index = viewControllers.firstIndex(where: { MTDSafeUnwrapViewController($0) == viewController }) else {
            return
        }
        
        viewControllers.remove(at: index)
        super.setViewControllers(viewControllers, animated: animated)
    }
    
    
    /// Push a view controller and do sth. when animation is done
    ///
    /// - Parameters:
    ///   - viewController: new view controller
    ///   - animated: use animation or not
    ///   - completion: animation complete callback block
    open func pushViewController(_ viewController: UIViewController, animated: Bool, completion: Completion?) {
        if let completionHandler = self.completionHandler {
            completionHandler(false)
        }
        self.completionHandler = completion
        self.pushViewController(viewController, animated: animated)
    }
    
    /// Pop current view controller on top with a complete handler
    ///
    /// - Parameters:
    ///   - animated: use animation or not
    ///   - completion: animation complete callback block
    /// - Returns: The current UIViewControllers(content controller) poped from the stack
    @discardableResult
    open func popViewController(animated: Bool, completion: Completion?) -> UIViewController? {
        if let completionHandler = self.completionHandler {
            completionHandler(false)
        }
        self.completionHandler = completion
        
        let vc = self.popViewController(animated: animated)
        if vc == nil {
            if let completionHandler = self.completionHandler {
                completionHandler(true)
                self.completionHandler = nil
            }
        }
        return vc
    }
    
    /// Pop to a specific view controller with a complete handler
    ///
    /// - Parameters:
    ///   - viewController: The view controller to pop to
    ///   - animated: use animation or not
    ///   - completion: complete handler
    /// - Returns: A array of UIViewControllers(content controller) poped from the stack
    @discardableResult
    open func popToViewController(_ viewController: UIViewController, animated: Bool, completion: Completion?) -> [UIViewController]? {
        if let completionHandler = self.completionHandler {
            completionHandler(false)
        }
        self.completionHandler = completion
        
        let viewControllers = self.popToViewController(viewController, animated: animated)
        
        let count = viewControllers?.count ?? 0
        if count == 0 {
            if let completionHandler = self.completionHandler {
                completionHandler(true)
                self.completionHandler = nil
            }
        }
        
        return viewControllers
    }
    
    /// Pop to root view controller with a complete handler
    ///
    /// - Parameters:
    ///   - animated: use animation or not
    ///   - completion: complete handler
    /// - Returns: A array of UIViewControllers(content controller) poped from the stack
    @discardableResult
    open func popToRootViewController(animated: Bool, completion: Completion?) -> [UIViewController]? {
        if let completionHandler = self.completionHandler {
            completionHandler(false)
        }
        self.completionHandler = completion
        
        let viewControllers = self.popToRootViewController(animated: animated)
        
        let count = viewControllers?.count ?? 0
        if count == 0 {
            if let completionHandler = self.completionHandler {
                completionHandler(true)
                self.completionHandler = nil
            }
        }
        
        return viewControllers
    }
    
    
    public func performBackAction(in navigationView: MTDNavigationView) {
        self.popViewController(animated: true)
    }
    
}
// MARK: - UINavigationControllerDelegate Proxy
extension MTDNavigationController: UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let isRootVC = viewController.isEqual(self.viewControllers.first)
        let unwrapped = MTDSafeUnwrapViewController(viewController)
        let mtd_vc = unwrapped.mtd
        let navigationView = mtd_vc.navigationView
        if navigationView.automaticallyAdjustsBackItemHidden {
            mtd_vc.navigationView.backButton.isHidden = isRootVC
        }
        self.mtd_delegate?.navigationController?(navigationController,
                                                willShow: unwrapped,
                                                animated: animated)
    }
    
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        let unwrapped = MTDSafeUnwrapViewController(viewController)
        let mtd_vc = unwrapped.mtd
        
        let navigationView = mtd_vc.navigationView
        if mtd_vc.navigationView.delegate == nil {
            navigationView.delegate = self
        }
        
        if !mtd_vc.hasSetInteractivePop {
            mtd_vc.disableInteractivePop = navigationView.isHidden
        }
        
        MTDNavigationController.attemptRotationToDeviceOrientation()
        
        self.mtd_delegate?.navigationController?(navigationController,
                                                didShow: unwrapped,
                                                animated: animated)
        
        if let completionHandler = self.completionHandler {
            self.completionHandler = nil
            if animated {
                DispatchQueue.main.async {
                    completionHandler(true)
                }
            } else {
                completionHandler(true)
            }
        }
    }
    
    
    public func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        return self.mtd_delegate?.navigationControllerSupportedInterfaceOrientations?(navigationController) ?? .all
    }
    
    public func navigationControllerPreferredInterfaceOrientationForPresentation(_ navigationController: UINavigationController) -> UIInterfaceOrientation {
        return self.mtd_delegate?.navigationControllerPreferredInterfaceOrientationForPresentation?(navigationController) ?? .portrait
    }
    
    public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.mtd_delegate?.navigationController?(navigationController,
                                                       interactionControllerFor: animationController)
    }
    
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.mtd_delegate?.navigationController?(navigationController,
                                                       animationControllerFor: operation,
                                                       from: MTDSafeUnwrapViewController(fromVC),
                                                       to: MTDSafeUnwrapViewController(toVC))
    }
}

extension MTDNavigationController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer.isEqual(self.interactivePopGestureRecognizer) else {
            return true
        }
        let viewControllers = self.viewControllers
        guard viewControllers.count > 1, let topViewController = self.topViewController.map({ MTDSafeUnwrapViewController($0) }) else {
            return false
        }
        return !topViewController.mtd.disableInteractivePop
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer == self.interactivePopGestureRecognizer
    }
}

