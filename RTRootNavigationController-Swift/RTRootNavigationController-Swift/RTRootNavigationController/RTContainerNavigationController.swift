//
//  RTContainerNavigationController.swift
//  RTRootNavigationController-Swift
//
//  Created by wuweixin on 2019/7/22.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit

class RTContainerNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.interactivePopGestureRecognizer?.isEnabled = false
        
        if let navigationBar = self.navigationController?.navigationBar {
            self.navigationBar.isTranslucent = navigationBar.isTranslucent
            self.navigationBar.tintColor = navigationBar.tintColor
            self.navigationBar.barTintColor = navigationBar.barTintColor
            self.navigationBar.barStyle = navigationBar.barStyle
            self.navigationBar.backgroundColor = navigationBar.backgroundColor
            
            self.navigationBar.setBackgroundImage(navigationBar.backgroundImage(for: .default),
                                                  for: .default)
            self.navigationBar.setTitleVerticalPositionAdjustment(navigationBar.titleVerticalPositionAdjustment(for: .default),
                                                                  for: .default)
            
            self.navigationBar.titleTextAttributes = navigationBar.titleTextAttributes
            self.navigationBar.shadowImage = navigationBar.shadowImage
            self.navigationBar.backIndicatorImage = navigationBar.backIndicatorImage
            self.navigationBar.backIndicatorTransitionMaskImage = navigationBar.backIndicatorTransitionMaskImage
        }
    }

}
