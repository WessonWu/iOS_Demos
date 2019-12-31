import RxSwift
import HandyJSON

// rx supports
public func rx_request(_ target: ThorAPI, callbackQueue: DispatchQueue? = nil) -> Single<ThorResponse> {
    return AnyThorProvider.default.rx.thorRequest(target, callbackQueue: callbackQueue)
}

public func rx_requestPaging(_ target: ThorPagingAPI, callbackQueue: DispatchQueue? = nil) -> Single<ThorResponse> {
    return AnyThorProvider.default.rx.thorPagingRequest(target, callbackQueue: callbackQueue)
}


public extension ThorAPI {
    func rx_request(callbackQueue: DispatchQueue? = nil) -> Single<ThorResponse> {
        return Thor.rx_request(self, callbackQueue: callbackQueue)
    }
    
    func rx_requestModel<Model>(type: Model.Type, transform: @escaping (Any?) throws -> Model?, callbackQueue: DispatchQueue? = nil) -> Single<ThorModelValue<Model>> {
        return Thor.rx_request(self, callbackQueue: callbackQueue).mapThorValue().mapModel(type: type, transform: transform)
    }
    
    func rx_requestModel<Model: HandyJSON>(type: Model.Type, callbackQueue: DispatchQueue? = nil) -> Single<ThorModelValue<Model>> {
        return Thor.rx_request(self, callbackQueue: callbackQueue).mapThorValue().mapModel(type: type)
    }
    
    func rx_requestArray<Model>(type: Model.Type, transform: @escaping (Any?) throws -> [Model]?, callbackQueue: DispatchQueue? = nil) -> Single<ThorArrayValue<Model>> {
        return Thor.rx_request(self, callbackQueue: callbackQueue).mapThorValue().mapArray(type: type, transform: transform)
    }
    
    func rx_requestArray<Model: HandyJSON>(type: Model.Type, callbackQueue: DispatchQueue? = nil) -> Single<ThorArrayValue<Model>> {
        return Thor.rx_request(self, callbackQueue: callbackQueue).mapThorValue().mapArray(type: type)
    }
}


public extension ThorPagingAPI {
    func rx_request(callbackQueue: DispatchQueue? = nil) -> Single<ThorResponse> {
        return Thor.rx_requestPaging(self, callbackQueue: callbackQueue)
    }
    
    func rx_requestModel<Model>(type: Model.Type, transform: @escaping (Any?) throws -> Model?, callbackQueue: DispatchQueue? = nil) -> Single<ThorModelValue<Model>> {
        return Thor.rx_requestPaging(self, callbackQueue: callbackQueue).mapThorValue().mapModel(type: type, transform: transform)
    }
    
    func rx_requestModel<Model: HandyJSON>(type: Model.Type, callbackQueue: DispatchQueue? = nil) -> Single<ThorModelValue<Model>> {
        return Thor.rx_requestPaging(self, callbackQueue: callbackQueue).mapThorValue().mapModel(type: type)
    }
    
    func rx_requestArray<Model>(type: Model.Type, transform: @escaping (Any?) throws -> [Model]?, callbackQueue: DispatchQueue? = nil) -> Single<ThorArrayValue<Model>> {
        return Thor.rx_requestPaging(self, callbackQueue: callbackQueue).mapThorValue().mapArray(type: type, transform: transform)
    }
    
    func rx_requestArray<Model: HandyJSON>(type: Model.Type, callbackQueue: DispatchQueue? = nil) -> Single<ThorArrayValue<Model>> {
        return Thor.rx_requestPaging(self, callbackQueue: callbackQueue).mapThorValue().mapArray(type: type)
    }
}
