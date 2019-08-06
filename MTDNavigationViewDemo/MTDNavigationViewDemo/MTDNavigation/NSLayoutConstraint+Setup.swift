//
//  NSLayoutConstraint+Setup.swift
//  MTDNavigationViewDemo
//
//  Created by wuweixin on 2019/8/6.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {
    @discardableResult
    func setup(_ block: (NSLayoutConstraint) -> Void) -> NSLayoutConstraint {
        block(self)
        return self
    }
}
