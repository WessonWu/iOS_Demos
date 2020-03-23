import Foundation
import Moya

/// 不会自动处理paing参数
@discardableResult
public func request(_ target: ThorAPI, callbackQueue: DispatchQueue? = nil, progress: ProgressBlock? = nil, completion: @escaping ThorCompletion) -> Cancellable {
    return AnyThorProvider.default.thorRequest(target, callbackQueue: callbackQueue, progress: progress, completion: completion)
}

/// 会自动处理paging参数
@discardableResult
public func requestPaging(_ target: ThorPagingAPI, callbackQueue: DispatchQueue? = nil, progress: ProgressBlock? = nil, completion: @escaping ThorCompletion) -> Cancellable {
    return AnyThorProvider.default.thorPagingRequest(target, callbackQueue: callbackQueue, progress: progress, completion: completion)
}

public extension ThorAPI {
    @discardableResult
    func request(callbackQueue: DispatchQueue? = nil, progress: ProgressBlock? = nil, completion: @escaping ThorCompletion) -> Cancellable {
        return Thor.request(self, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }
}

public extension ThorPagingAPI {
    @discardableResult
    func request(callbackQueue: DispatchQueue? = nil, progress: ProgressBlock? = nil, completion: @escaping ThorCompletion) -> Cancellable {
        return Thor.requestPaging(self, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }
}
