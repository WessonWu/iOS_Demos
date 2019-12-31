import Foundation
import HandyJSON
import RxSwift

extension PrimitiveSequence where Trait == SingleTrait, Element == ThorValue {
    public func mapModel<M>(type: M.Type, transform: @escaping (Any?) throws -> M?) -> Single<ThorModelValue<M>> {
        return flatMap({ (value) -> Single<ThorModelValue<M>> in
            return Single.just(try value.mapModel(type: M.self, transform: transform))
        })
    }
    
    public func mapModel<M: HandyJSON>(type: M.Type) -> Single<ThorModelValue<M>> {
        return flatMap({ (value) -> Single<ThorModelValue<M>> in
            return Single.just(try value.mapModel(type: M.self))
        })
    }
    
    public func mapArray<M>(type: M.Type, transform: @escaping (Any?) throws -> [M]?) -> Single<ThorArrayValue<M>> {
        return flatMap({ (value) -> Single<ThorArrayValue<M>> in
            return Single.just(try value.mapArray(type: M.self, transform: transform))
        })
    }
    
    public func mapArray<M: HandyJSON>(type: M.Type) -> Single<ThorArrayValue<M>> {
        return flatMap({ (value) -> Single<ThorArrayValue<M>> in
            return Single.just(try value.mapArray(type: M.self))
        })
    }
}

