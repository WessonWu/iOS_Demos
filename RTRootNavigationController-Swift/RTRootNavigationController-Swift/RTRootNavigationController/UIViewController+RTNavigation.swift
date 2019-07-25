//
//  UIViewController+RTNavigation.swift
//  RTRootNavigationController-Swift
//
//  Created by wuweixin on 2019/7/24.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit

extension UIViewController: RTNavigationCompatible {}

public extension RTNavigation where Base: UIViewController {
    var navigationController: RTRootNavigationController? {
        var vc: UIViewController = self.base
        while !vc.isKind(of: RTRootNavigationController.self) {
            guard let navigationController = vc.navigationController else {
                return nil
            }
            vc = navigationController
        }
        return vc as? RTRootNavigationController
    }
    
    var navigationBarClass: AnyClass? {
        return (base as? RTNavigationBarCustomizable)?.navigationBarClass
    }
    
    var disableInteractivePop: Bool {
        return (base as? RTNavigationInteractable)?.disableInteractivePop ?? false
    }
}
