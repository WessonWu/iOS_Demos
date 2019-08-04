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
            view.owning = base
            objc_setAssociatedObject(base, &AssociatedKeys.navigationView, view, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return view
        }
        let view = MTDNavigationView()
        view.owning = base
        objc_setAssociatedObject(base, &AssociatedKeys.navigationView, view, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return view
    }
    
    var disableInteractivePop: Bool {
        get {
            return objc_getAssociatedObject(base, &AssociatedKeys.disableInteractivePop) as? Bool ?? false
        }
        
        set {
            objc_setAssociatedObject(base, &AssociatedKeys.disableInteractivePop, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    var isNavigationViewHidden: Bool {
        return navigationView.isNavigationViewHidden
    }
    
    func setNavigationViewHidden(_ hidden: Bool, animated: Bool) {
        wrapperController?.setNavigationViewHidden(hidden, animated: animated)
    }
}

internal extension MTDNavigation where Base: UIViewController {
    var hasSetInteractivePop: Bool {
        return (objc_getAssociatedObject(base, &AssociatedKeys.disableInteractivePop) as? Bool) != nil
    }
}
