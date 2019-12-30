//
//  Timeoutable.swift
//  Thor
//
//  Created by wuweixin on 2019/12/30.
//

import Foundation


public protocol Timeoutable {
    var timeoutInterval: TimeInterval { get }
}

public extension Timeoutable {
    var timeoutInterval: TimeInterval {
        return 10
    }
}
