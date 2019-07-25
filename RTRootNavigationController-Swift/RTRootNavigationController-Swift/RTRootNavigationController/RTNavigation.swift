//
//  RTNavigation.swift
//  RTRootNavigationController-Swift
//
//  Created by wuweixin on 2019/7/24.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import Foundation

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

public protocol RTNavigationInteractable {
    var disableInteractivePop: Bool { get }
}

public extension RTNavigationInteractable {
    var disableInteractivePop: Bool {
        return false
    }
}
