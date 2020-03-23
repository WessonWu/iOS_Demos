import Foundation
import Moya

public protocol ResponseType: CustomDebugStringConvertible, Equatable {
    var statusCode: Int { get }
    var data: Data { get }
    var request: URLRequest? { get }
    var response: HTTPURLResponse? { get }
}

public extension ResponseType {
    var isFromCache: Bool {
        return response?.isFromCache ?? false
    }
    
    /// A text description of the `Response`.
    var description: String {
        return "Status Code: \(statusCode), Data Length: \(data.count)"
    }
    
    /// A text description of the `Response`. Suitable for debugging.
    var debugDescription: String {
        return description
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.statusCode == rhs.statusCode
            && lhs.data == rhs.data
            && lhs.response == rhs.response
    }
}

extension Moya.Response: ResponseType {}
