//
//  Thor.swift
//  Thor
//
//  Created by wuweixin on 2019/12/30.
//

import Foundation
import Moya

@discardableResult
public func request<API: ThorAPI>(_ api: API,
                                  callbackQueue: DispatchQueue? = .none,
                                  progress: ProgressBlock? = .none,
                                  completion: @escaping Moya.Completion) -> Cancellable {
    return AnyThorProvider.default.request(AnyThorAPI(target: api),
                                           callbackQueue: callbackQueue,
                                           progress: progress,
                                           completion: completion)
}

@discardableResult
public func requestPaging<API: ThorPagingAPI>(_ api: API,
                                  callbackQueue: DispatchQueue? = .none,
                                  progress: ProgressBlock? = .none,
                                  completion: @escaping ThorCompletion) -> Cancellable {
    return SimpleProvider.default.requestPaging(api, callbackQueue: callbackQueue, progress: progress, completion: completion)
}
