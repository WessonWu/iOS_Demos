//
//  UINavigationController+LayoutMargins.swift
//  RTRootNavigationController-Swift
//
//  Created by wuweixin on 2019/7/31.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit

extension RTContainerNavigationController {
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.navigationBar.subviews.forEach { (subview) in
            subview.layoutMargins.left = 16
            subview.layoutMargins.right = 16
            if #available(iOS 11, *) {
                subview.directionalLayoutMargins.leading = 16
                subview.directionalLayoutMargins.trailing = 16
            }
        }
    }
}
