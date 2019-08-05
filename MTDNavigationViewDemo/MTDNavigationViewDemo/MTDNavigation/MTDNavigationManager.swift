//
//  MTDNavigationManager.swift
//  MTDNavigationViewDemo
//
//  Created by wuweixin on 2019/8/5.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit

public protocol MTDNavigationViewBuilderType {
    func backButton() -> UIControl
    func build() -> MTDNavigationView
}

public final class MTDNavigationViewDefaultBuilder: MTDNavigationViewBuilderType {
    
    public func backButton() -> UIControl {
        return BackButton(image: UIImage(named: "nav_bar_back_ic")?.withRenderingMode(.alwaysTemplate))
    }
    
    public func build() -> MTDNavigationView {
        return MTDNavigationView()
    }
}

public final class MTDNavigationManager {
    public static var navigationViewBuilder: MTDNavigationViewBuilderType = MTDNavigationViewDefaultBuilder()
    
    public class func backButton(with builder: MTDNavigationViewBuilderType = MTDNavigationManager.navigationViewBuilder) -> UIControl {
        return builder.backButton()
    }
    
    public class func build(with builder: MTDNavigationViewBuilderType = MTDNavigationManager.navigationViewBuilder) -> MTDNavigationView {
        return builder.build()
    }
}
