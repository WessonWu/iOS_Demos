import Foundation
import Moya

public typealias ThorError = Moya.MoyaError

public extension ThorError {
    var urlError: URLError? {
        if case let .underlying(error as URLError, _) = self {
            return error
        }
        return nil
    }
    
    var isNetworkError: Bool {
        return urlError != nil
    }
    
    var networkError: NSError? {
        return urlError as NSError?
    }
    
    var isInternetConnectionLost: Bool {
        guard let error = urlError else {
            return false
        }
        // 无网络code: (-1009: 无代理), (-1005: 有代理)
        return error.code == .notConnectedToInternet || error.code == .networkConnectionLost
    }
    
    var isRequestTimeout: Bool {
        return urlError?.code == .timedOut
    }
}
