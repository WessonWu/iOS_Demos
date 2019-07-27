//
//  RTNavigation.swift
//  RTRootNavigationController-Swift
//
//  Created by wuweixin on 2019/7/24.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit

public final class RTNavigation<Base> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol RTNavigationCompatible {
    associatedtype CompatibleType
    var rt: CompatibleType { get }
}

public extension RTNavigationCompatible {
    var rt: RTNavigation<Self> {
        return RTNavigation(self)
    }
}


public protocol RTNavigationBarCustomizable {
    var navigationBarClass: AnyClass? { get }
}

public extension RTNavigationBarCustomizable {
    var navigationBarClass: AnyClass? {
        return nil
    }
}

public protocol RTNavigationItemCustomizable {
    func customBackItemWithTarget(_ target: Any?, action: Selector) -> UIBarButtonItem?
}

public extension RTNavigationItemCustomizable {
    func customBackItemWithTarget(_ target: Any?, action: Selector) -> UIBarButtonItem? {
        return nil
    }
}
