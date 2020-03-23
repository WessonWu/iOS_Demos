import Foundation

public protocol RequestCacheable {
    var needCache: Bool { get } // 是否需要缓存
}

public extension RequestCacheable {
    var needCache: Bool {
        return false
    }
}
