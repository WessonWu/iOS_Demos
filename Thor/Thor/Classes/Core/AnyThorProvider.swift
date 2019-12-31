//
//  AnyThorProvider.swift
//  Thor
//
//  Created by wuweixin on 2019/12/30.
//

import Foundation
import Moya
import Result

public typealias ThorCompletion = (_ result: Result<ThorResponse, ThorError>) -> Void

public final class AnyThorProvider: Moya.MoyaProvider<AnyThorAPI> {
    public static let `default` = AnyThorProvider(plugins: [ThorRequestTimeoutPlugin(), ThorRequestCachePlugin()])
    @discardableResult
    public func thorRequest(_ target: ThorAPI, callbackQueue: DispatchQueue? = nil, progress: ProgressBlock? = nil, completion: @escaping ThorCompletion) -> Cancellable {
        return internalThorRequest(target, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }
    
    @discardableResult
    public func thorPagingRequest(_ target: ThorPagingAPI, callbackQueue: DispatchQueue? = nil, progress: ProgressBlock? = nil, completion: @escaping ThorCompletion) -> Cancellable {
        return internalThorRequest(target,
                                   callbackQueue: callbackQueue,
                                   progress: progress,
                                   completion: completion)
        { [weak target] (result) in
            switch result {
                case .success(let response):
                    /// 自动解析page参数，如果想自己解析，可以在返回结果中自己解析并更新值
                    if let pagingParams = AutoPagingParamsParser.deserialize(from: response.value.result as? [String: Any]) {
                        target?.paging.update(pagingParams)
                    } else {
                        target?.paging.update(AutoPagingParamsParser())
                    }
                case .failure:
                    // 出现错误，根据需要恢复状态
                    target?.paging.recover()
            }
        }
    }
}

internal extension AnyThorProvider {
    typealias ExtraCompletionHandler = (Result<ThorResponse, ThorError>) -> Void
    
    func internalThorRequest(_ target: ThorAPI,
                     callbackQueue: DispatchQueue?,
                     progress: ProgressBlock?,
                     completion: @escaping ThorCompletion,
                     extraHandler: ExtraCompletionHandler? = nil) -> Cancellable {
        // Result<Response, MoyaError> -> Result<ThorResponse, ThorError>
        let completionHandler: Completion = { result in
            let finalResult = result.flatMap { (response) -> Result<ThorResponse, MoyaError> in
                let result: Result<ThorResponse, MoyaError>
                if let thorRespose = ThorResponse(original: response) {
                    // 自动验证code流程
                    let value = thorRespose.value
                    if let codes = target.validCodes, !value.validate(codes: codes) {
                        result = .failure(ThorError.underlying(ThorValueError.code(value.code, value.message), response))
                    } else {
                        result = .success(thorRespose)
                    }
                } else {
                    result = .failure(ThorError.underlying(ThorValueError.format, response))
                }
                extraHandler?(result)
                return result
            }
            completion(finalResult)
        }
        return super.request(AnyThorAPI(target), callbackQueue: callbackQueue, progress: progress, completion: completionHandler)
    }
}

// MARK: - Deprecated
@available(*, deprecated)
public typealias SimpleProvider = AnyThorProvider
@available(*, deprecated)
public extension AnyThorProvider {
    @discardableResult
    func request<API: ThorAPI>(_ api: API,
                               callbackQueue: DispatchQueue? = .none,
                               progress: ProgressBlock? = .none,
                               completion: @escaping ThorCompletion) -> Cancellable {
        return thorRequest(api, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }
    
    @discardableResult
    func requestPaging<API: ThorPagingAPI>(_ api: API,
                                           callbackQueue: DispatchQueue? = .none,
                                           progress: ProgressBlock? = .none,
                                           completion: @escaping ThorCompletion) -> Cancellable {
        return thorPagingRequest(api, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }
}
