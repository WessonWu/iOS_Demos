import Foundation
import Moya

public protocol ResponseConvertible {
    func asResponse() -> Moya.Response
}

public extension ResponseType where Self: ResponseConvertible {
    func mapThorValue() throws -> ThorValue {
        guard let value = ThorValue.deserialize(from: String(data: data, encoding: .utf8)) else {
            throw ThorError.underlying(ThorValueError.format, self.asResponse())
        }
        return value
    }
}

extension Moya.Response: ResponseConvertible {
    public func asResponse() -> Response {
        return self
    }
}
