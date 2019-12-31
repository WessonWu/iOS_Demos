//
//  ThorRequestTimeoutable.swift
//  Thor
//
//  Created by wuweixin on 2019/12/30.
//

import Foundation


public protocol ThorRequestTimeoutable {
    var timeoutInterval: TimeInterval { get }
}

public extension ThorRequestTimeoutable {
    var timeoutInterval: TimeInterval {
        return 10
    }
}
