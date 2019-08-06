//
//  MTDNavigation+UIViewController.swift
//  MTDNavigationViewDemo
//
//  Created by wuweixin on 2019/8/3.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit

internal struct AssociatedKeys {
    static var navigationView = "mtd_navigationView"
    static var disableInteractivePop = "mtd_disableInteractivePop"
    static var adjustedContentInsetTop = "mtd_adjustedContentInsetTop"
    static var adjustedSafeAreaInsetTop = "mtd_adjustedSafeAreaInsetTop"
}

extension UIViewController: MTDNavigationCompatible {}

public extension MTDNavigation where Base: UIViewController {
    var navigationController: MTDNavigationController? {
        var vc: UIViewController = self.base
        while !vc.isKind(of: MTDNavigationController.self) {
            guard let navigationController = vc.navigationController else {
                return nil
            }
            vc = navigationController
        }
        return vc as? MTDNavigationController
    }
    
    var wrapperController: MTDWrapperController? {
        return base.parent as? MTDWrapperController
    }
    
    var unwrapped: UIViewController {
        return MTDSafeUnwrapViewController(base)
    }
    
    var navigationView: MTDNavigationView {
        if let view = objc_getAssociatedObject(base, &AssociatedKeys.navigationView) as? MTDNavigationView {
            return view
        }
        if let customizable = base as? MTDNavigationViewCustomizable {
            let view = customizable.navigationView
            objc_setAssociatedObject(base, &AssociatedKeys.navigationView, view, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return view
        }
        let view = MTDNavigationManager.build()
        objc_setAssociatedObject(base, &AssociatedKeys.navigationView, view, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return view
    }
    
    var disableInteractivePop: Bool {
        get {
            return disableInteractivePopAssociatedObject?.boolValue ?? false
        }
        
        set {
            objc_setAssociatedObject(base, &AssociatedKeys.disableInteractivePop, NSNumber(value: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var isNavigationViewHidden: Bool {
        return navigationView.isNavigationViewHidden
    }
    
    func setNavigationViewHidden(_ hidden: Bool, animated: Bool) {
        wrapperController?.setNavigationViewHidden(hidden, animated: animated)
    }
    
    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        let wrapped = MTDSafeWrapViewController(viewControllerToPresent)
        let mtd_vc = viewControllerToPresent.mtd
        let navigationView = mtd_vc.navigationView
        if navigationView.delegate == nil {
            navigationView.delegate = wrapped as? MTDWrapperController
        }
        base.present(wrapped, animated: flag, completion: completion)
    }
    
    func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        if let vc = base.parent as? MTDWrapperController {
            vc.dismiss(animated: flag, completion: completion)
        } else {
            base.dismiss(animated: flag, completion: completion)
        }
    }
}

internal extension MTDNavigation where Base: UIViewController {
    var disableInteractivePopAssociatedObject: NSNumber? {
        return objc_getAssociatedObject(base, &AssociatedKeys.disableInteractivePop) as? NSNumber
    }
    
    var hasSetInteractivePop: Bool {
        return disableInteractivePopAssociatedObject != nil
    }
}
