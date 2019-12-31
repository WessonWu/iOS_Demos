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

public enum ThorValueError: Swift.Error {
    case format
    case resultMapping(Swift.Error, ThorResponse)
    case code(Int, String)
}

extension ThorValueError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .format:
            return "Invalid thor value format."
        case .resultMapping:
            return "Failed to mapping result."
        case let .code(code, message):
            return "Invalid (code: \(code), message: \(message))"
        }
    }
}

public extension ThorError {
    var valueError: ThorValueError? {
        switch self {
        case let .underlying(error, _):
            if let valueError = error as? ThorValueError {
                return valueError
            }
        default: break
        }
        return nil
    }
}
