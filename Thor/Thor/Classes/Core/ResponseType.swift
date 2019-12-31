import Foundation
import Moya

public protocol ResponseConvertible {
    func asResponse() -> Moya.Response
}

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

public extension ResponseType where Self: ResponseConvertible {
    func mapThorValue() throws -> ThorValue {
        guard let value = ThorValue.deserialize(from: String(data: data, encoding: .utf8)) else {
            throw ThorError.underlying(ThorValueError.format, self.asResponse())
        }
        return value
    }
}


extension Moya.Response: ResponseType {}
extension Moya.Response: ResponseConvertible {
    public func asResponse() -> Response {
        return self
    }
}
