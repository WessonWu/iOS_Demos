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
    
    /// use system original back bar item or custom back bar item returned by
    /// (UIBarButtonItem*)customBackItemWithTarget:action: , default is NO
    /// Warning: Set this to YES will INCREASE memory usage!
    @IBInspectable
    open var useSystemBackBarButtonItem: Bool = false
    
    /// Weather each individual navigation bar uses the visual style of root navigation bar. Default is NO
    @IBInspectable
    open var transferNavigationBarAttributes: Bool = false
    
    open override var delegate: UINavigationControllerDelegate? {
        get {
            return super.delegate
        }
        set {
            self.rt_delegate = newValue
        }
    }
    
    weak var rt_delegate: UINavigationControllerDelegate?
    
    var completionHandler: Completion?
    

    /// Init with a root view controller without wrapping into a navigation controller
    ///
    /// - Parameter rootViewController: The root viewController
    public convenience init(rootViewControllerNoWrapping rootViewController: UIViewController) {
        self.init(rootViewController: RTContainerController(contentViewController: rootViewController))
    }
    
    // MARK: - Override
    
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
        
        super.delegate = self
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
    
    @discardableResult
    open override func popViewController(animated: Bool) -> UIViewController? {
        return super.popViewController(animated: animated).map {
            RTSafeUnwrapViewController($0)
        }
    }
    
    @discardableResult
    open override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        return super.popToRootViewController(animated: animated).map({ (viewControllers) -> [UIViewController] in
            viewControllers.map { RTSafeUnwrapViewController($0) }
        })
    }
    
    @discardableResult
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
    
    // MARK: - Custom Public Method (Push & Pop)
    
    
    /// Remove a content view controller from the stack
    ///
    /// - Parameters:
    ///   - viewController: the content view controller
    ///   - animated: use animation or not
    open func removeViewController(_ viewController: UIViewController, animated: Bool = false) {
        var viewControllers = self.viewControllers
        guard let index = viewControllers.firstIndex(where: { RTSafeUnwrapViewController($0) == viewController }) else {
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
    
}

// MARK: - Internal
extension RTRootNavigationController {
    func installsLeftBarButtonItemIfNeeded(for viewController: UIViewController) {
        let rootVC = self.viewControllers.first.map { RTSafeUnwrapViewController($0) }
        let isRootVC = viewController.isEqual(rootVC)
        let hasSetLeftItem = viewController.navigationItem.leftBarButtonItem != nil
        
        if !isRootVC && !self.useSystemBackBarButtonItem && !hasSetLeftItem {
            if let backItem = viewController.rt.customBackItemWithTarget(self, action: #selector(onBack(_:))) {
                viewController.navigationItem.leftBarButtonItem = backItem
            } else {
                viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back",
                                                                                  style: .plain,
                                                                                  target: self,
                                                                                  action: #selector(onBack(_:)))
            }
        }
    }
    
    @objc
    func onBack(_ sender: Any?) {
        self.popViewController(animated: true)
    }
}

// MARK: - UINavigationControllerDelegate Proxy
extension RTRootNavigationController: UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let isRootVC = viewController.isEqual(self.viewControllers.first)
        let unwrapped = RTSafeUnwrapViewController(viewController)
        if !isRootVC && unwrapped.isViewLoaded {
            let hasSetLeftItem = unwrapped.navigationItem.leftBarButtonItem != nil
            let rt_vc = unwrapped.rt
            if hasSetLeftItem && !rt_vc.hasSetInteractivePop {
                rt_vc.disableInteractivePop = true
            } else if !rt_vc.hasSetInteractivePop {
                rt_vc.disableInteractivePop = false
            }
            installsLeftBarButtonItemIfNeeded(for: unwrapped)
        }
        
        self.rt_delegate?.navigationController?(navigationController,
                                                willShow: unwrapped,
                                                animated: animated)
    }
    
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        let isRootVC = viewController.isEqual(self.viewControllers.first)
        let unwrapped = RTSafeUnwrapViewController(viewController)
        let rt_vc = unwrapped.rt
        if rt_vc.disableInteractivePop {
            self.interactivePopGestureRecognizer?.delegate = nil
            self.interactivePopGestureRecognizer?.isEnabled = false
        } else {
            self.interactivePopGestureRecognizer?.delaysTouchesBegan = true
            self.interactivePopGestureRecognizer?.delegate = self
            self.interactivePopGestureRecognizer?.isEnabled = !isRootVC
        }
        
        RTRootNavigationController.attemptRotationToDeviceOrientation()
        
        self.rt_delegate?.navigationController?(navigationController,
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
        return self.rt_delegate?.navigationControllerSupportedInterfaceOrientations?(navigationController) ?? .all
    }
    
    public func navigationControllerPreferredInterfaceOrientationForPresentation(_ navigationController: UINavigationController) -> UIInterfaceOrientation {
        return self.rt_delegate?.navigationControllerPreferredInterfaceOrientationForPresentation?(navigationController) ?? .portrait
    }
    
    public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.rt_delegate?.navigationController?(navigationController,
                                                       interactionControllerFor: animationController)
    }
    
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.rt_delegate?.navigationController?(navigationController,
                                                       animationControllerFor: operation,
                                                       from: RTSafeUnwrapViewController(fromVC),
                                                       to: RTSafeUnwrapViewController(toVC))
    }
}

extension RTRootNavigationController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer == self.interactivePopGestureRecognizer
    }
}
