import Foundation

public protocol RequestTimeoutable {
    var timeoutInterval: TimeInterval { get }
}

public extension RequestTimeoutable {
    var timeoutInterval: TimeInterval {
        return 10
    }
}
