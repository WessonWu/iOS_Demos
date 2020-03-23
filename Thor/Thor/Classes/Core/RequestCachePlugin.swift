import Foundation
import Moya
import Result

open class RequestCachePlugin: PluginType {
    open func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var result = request
        // 除了get之外，不支持缓存
        if target.isCacheEnabled {
            result.cachePolicy = .useProtocolCachePolicy
        } else {
            result.cachePolicy = .reloadIgnoringCacheData
        }
        return result
    }
    
    open func process(_ result: Result<Response, MoyaError>, target: TargetType) -> Result<Response, MoyaError> {
        guard target.isCacheEnabled else {
            return result
        }
        switch result {
        case let .success(response):
            if !response.isFromCache, let request = response.request, let httpResponse = response.response {
                URLCacheManager.shared.storeCachedResponse(cachedResponse: CachedURLResponse(response: httpResponse, data: response.data), for: request)
            }
        case let .failure(error):
            // 无网络连接时读取缓存
            if let request = error.response?.request, error.isInternetConnectionLost {
                if let cachedResponse = URLCacheManager.shared.cachedResponse(for: request),
                    let cachedHttpResponse = cachedResponse.response as? HTTPURLResponse {
                    /// 缓存读取成功
                    return convertResponseToResult(cachedHttpResponse, request: request, data: cachedResponse.data, error: nil)
                }
            }
        }
        return result
    }
}

fileprivate extension TargetType {
    var isCacheEnabled: Bool {
        return method == .get && ((self as? RequestCacheable)?.needCache ?? false)
    }
}

