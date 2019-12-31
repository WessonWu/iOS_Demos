//
//  Cacheable.swift
//  Thor
//
//  Created by wuweixin on 2019/12/30.
//

import Foundation

public protocol ThorRequestCacheable {
    var needCache: Bool { get } // 是否需要缓存
}

public extension ThorRequestCacheable {
    var needCache: Bool {
        return false
    }
}
