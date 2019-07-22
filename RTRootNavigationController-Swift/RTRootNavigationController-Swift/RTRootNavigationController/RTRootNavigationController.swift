//
//  RTRootNavigationController.swift
//  RTRootNavigationController-Swift
//
//  Created by wuweixin on 2019/7/22.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit

@IBDesignable
public class RTRootNavigationController: UINavigationController {
    /*!
     *  @brief use system original back bar item or custom back bar item returned by
     *  @c -(UIBarButtonItem*)customBackItemWithTarget:action: , default is NO
     *  @warning Set this to @b YES will @b INCREASE memory usage!
     */
    public var useSystemBackBarButtonItem: Bool = false
    
    /// Weather each individual navigation bar uses the visual style of root navigation bar. Default is @b NO
    public var transferNavigationBarAttributes: Bool = false
}

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
