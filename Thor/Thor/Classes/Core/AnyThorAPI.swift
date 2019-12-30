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
    
    public init(target: ThorAPI) {
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
    // 建议还是使用task，灵活性更强
    public var parameters: [String: Any]? {
        return target.parameters
    }
    
    // 约定合法的code(自动处理) 如果返回nil则自行处理
    public var validCodes: Set<Int>? {
        return target.validCodes
    }
}
