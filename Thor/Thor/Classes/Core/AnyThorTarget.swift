import Foundation
import Moya

public struct AnyThorTarget {
    public let target: ThorTargetType
    
    public init(_ target: ThorTargetType) {
        self.target = target
    }
}

extension AnyThorTarget: ThorTargetType {
    // MARK: - Moya.TargetType
    public var baseURL: URL {
        return target.baseURL
    }
    
    public var path: String {
        return target.path
    }

    public var method: Moya.Method {
        return target.method
    }
    
    public var sampleData: Data {
        return target.sampleData
    }

    public var task: Task {
        return target.task
    }

    public var validationType: ValidationType {
        return target.validationType
    }

    public var headers: [String: String]? {
        return target.headers
    }
    
    // MARK: - Timeoutable
    public var timeoutInterval: TimeInterval {
        return target.timeoutInterval
    }
    
    // MARK: - Cacheable
    public var needCache: Bool {
        return target.needCache
    }
}
