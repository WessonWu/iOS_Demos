import Foundation

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
