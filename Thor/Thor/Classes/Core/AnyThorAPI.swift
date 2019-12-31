//
//  AnyThorAPI.swift
//  Thor
//
//  Created by wuweixin on 2019/12/30.
//

import Foundation
import Moya

public struct AnyThorAPI {
    public let target: ThorAPI
    
    public init(_ target: ThorAPI) {
        self.target = target
    }
}

extension AnyThorAPI: ThorAPI {
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
    
    // MARK: - ThorAPI
    public var url: URL {
        return target.url
    }
    
    public var parameters: [String: Any]? {
        return target.parameters
    }

    public var validCodes: Set<Int>? {
        return target.validCodes
    }
}


// MARK: - Deprecated
@available(*, deprecated)
public typealias SimpleThorAPIWrapper = AnyThorAPI

@available(*, deprecated)
public extension SimpleThorAPIWrapper {
    init<API: ThorAPI>(api: API) {
        self.init(api)
    }
}
