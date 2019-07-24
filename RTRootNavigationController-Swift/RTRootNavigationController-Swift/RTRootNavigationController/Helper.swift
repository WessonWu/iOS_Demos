//
//  Helper.swift
//  RTRootNavigationController-Swift
//
//  Created by wuweixin on 2019/7/22.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit


@inline(__always) func RTSafeUnwrapViewController(_ controller: UIViewController) -> UIViewController {
    if let containerController = controller as? RTContainerController {
        return containerController.contentViewController
    }
    return controller
}

@inline(__always) func RTSafeWrapViewController(_ controller: UIViewController,
                              navigationBarClass: AnyClass? = nil,
                              withPlaceholder: Bool = false,
                              backItem: UIBarButtonItem? = nil,
                              backTitle: String? = nil) -> UIViewController {
    if let containerController = controller as? RTContainerController {
        return containerController
    }
    return RTContainerController(contentViewController: controller,
                                 navigationBarClass: navigationBarClass,
                                 withPlaceholderController: withPlaceholder,
                                 backBarButtonItem: backItem,
                                 backTitle: backTitle)
}
