//
//  CommonNavigationController.swift
//  ToolbarController
//
//  Created by wuweixin on 2019/7/9.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit

class CommonNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.delegate = self
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        viewController.hidesBottomBarWhenPushed = true
        super.pushViewController(viewController, animated: animated)
        if viewControllers.first == viewController {
            viewController.hidesBottomBarWhenPushed = false
        }
    }
}
