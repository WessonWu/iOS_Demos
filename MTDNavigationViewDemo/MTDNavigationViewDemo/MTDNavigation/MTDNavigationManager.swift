//
//  MTDNavigationManager.swift
//  MTDNavigationViewDemo
//
//  Created by wuweixin on 2019/8/5.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit

public protocol MTDNavigationViewBuilderType {
    func build() -> MTDNavigationView
}

public final class MTDNavigationViewDefaultBuilder: MTDNavigationViewBuilderType {
    public func build() -> MTDNavigationView {
        return MTDNavigationView()
    }
}

public final class MTDNavigationManager {
    public static var navigationViewBuilder: MTDNavigationViewBuilderType = MTDNavigationViewDefaultBuilder()
    
    public class func build(with builder: MTDNavigationViewBuilderType = MTDNavigationManager.navigationViewBuilder) -> MTDNavigationView {
        return builder.build()
    }
}
