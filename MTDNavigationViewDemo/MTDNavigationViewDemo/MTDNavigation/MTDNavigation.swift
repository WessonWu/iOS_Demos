//
//  MTDNavigation.swift
//  MTDNavigationViewDemo
//
//  Created by wuweixin on 2019/8/3.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit

public final class MTDNavigation<Base> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol MTDNavigationCompatible {
    associatedtype CompatibleType
    var mtd: CompatibleType { get }
}

public extension MTDNavigationCompatible {
    var mtd: MTDNavigation<Self> {
        return MTDNavigation(self)
    }
}


public protocol MTDNavigationViewCustomizable {
    var navigationView: MTDNavigationView { get }
}
