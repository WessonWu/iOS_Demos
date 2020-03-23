import Foundation
import HandyJSON

public protocol ThorValueMappable {
    associatedtype Result
    var code: Int { get set }
    var message: String { get set }
    var result: Result? { get set }
}

public protocol ThorValueType: ThorValueMappable where Self.Result == Any {}
public protocol ThorModelValueType: ThorValueMappable where Result == MappedModel {
    associatedtype MappedModel
}

public protocol ThorArrayValueType: ThorValueMappable where Result == [MappedModel] {
    associatedtype MappedModel
}

public struct ThorValue: ThorValueType, HandyJSON {
    public var code: Int
    public var message: String
    public var result: Any?
    
    public init() {
        code = -1
        message = "Empty Result"
        result = nil
    }
}

public struct ThorModelValue<Model>: ThorModelValueType {
    public typealias MappedModel = Model
    
    public var code: Int
    public var message: String
    public var result: Model?
}

public struct ThorArrayValue<Model>: ThorArrayValueType {
    public typealias MappedModel = Model
    
    public var code: Int
    public var message: String
    public var result: [Model]?
}


public extension ThorValue {
    @discardableResult
    func validate(codes: Set<Int>) -> Bool {
        guard codes.contains(self.code) else {
            return false
        }
        return true
    }
    
    func mapModel<M>(type: M.Type, transform: (Any?) throws -> M?) throws -> ThorModelValue<M> {
        do {
            let model = try transform(result)
            return ThorModelValue<M>(code: self.code, message: self.message, result: model)
        } catch {
            throw ThorError.underlying(error, nil)
        }
    }
    
    func mapArray<M>(type: M.Type, transform: (Any?) throws -> [M]?) throws -> ThorArrayValue<M> {
        do {
            let array = try transform(result)
            return ThorArrayValue<M>(code: self.code, message: self.message, result: array)
        } catch {
            throw ThorError.underlying(error, nil)
        }
    }
    
    func mapModel<M: HandyJSON>(type: M.Type) throws -> ThorModelValue<M> {
        return try mapModel(type: M.self, transform: { (value) -> M? in
            return M.deserialize(from: value as? [String: Any])
        })
    }
    
    func mapArray<M: HandyJSON>(type: M.Type) throws -> ThorArrayValue<M> {
        return try mapArray(type: M.self, transform: { (value) -> [M]? in
            return JSONDeserializer<M>.deserializeModelArrayFrom(array: value as? [Any])?.compactMap { $0 }
        })
    }
}
