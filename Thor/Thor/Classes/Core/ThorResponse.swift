import Foundation
import Moya

public struct ThorResponse {
    public let original: Moya.Response
    public let value: ThorValue

    public init(original: Moya.Response,
                value: ThorValue) {
        self.original = original
        self.value = value
    }
    
    public init?(original: Moya.Response) {
        guard let value = ThorValue.deserialize(from: String(data: original.data, encoding: .utf8)) else {
            return nil
        }
        self.init(original: original, value: value)
    }
}

extension ThorResponse: ResponseType {
    public var statusCode: Int {
        return original.statusCode
    }
    public var data: Data {
        return original.data
    }
    public var request: URLRequest? {
        return original.request
    }
    public var response: HTTPURLResponse? {
        return original.response
    }
}

extension ThorResponse: ResponseConvertible {
    public func asResponse() -> Response {
        return original
    }
}

public extension Moya.Response {
    func mapThorResponse() throws -> ThorResponse {
        guard let thorResponse = ThorResponse(original: self) else {
            throw ThorError.underlying(ThorValueError.format, self)
        }
        return thorResponse
    }
}
