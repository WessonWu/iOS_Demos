//
//  AnyThorProvider.swift
//  Thor
//
//  Created by wuweixin on 2019/12/30.
//

import Foundation
import Moya

struct ThorRequestTimeoutPlugin: PluginType {
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var result = request
        if let timeoutable = target as? Timeoutable {
            result.timeoutInterval = timeoutable.timeoutInterval
        }
        return result
    }
}

public final class AnyThorProvider: Moya.MoyaProvider<AnyThorAPI> {
    public static let `default` = AnyThorProvider(callbackQueue: nil,
                                                  manager: defaultAlamofireManager(),
                                                  plugins: [ThorRequestTimeoutPlugin()])
}
