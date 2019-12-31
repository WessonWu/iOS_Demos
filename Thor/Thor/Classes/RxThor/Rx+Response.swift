import Foundation
import RxSwift

extension PrimitiveSequence where Trait == SingleTrait, Element: ResponseType & ResponseConvertible {
    public func mapThorValue() -> Single<ThorValue> {
        return flatMap({ (response) -> Single<ThorValue> in
            return Single.just(try response.mapThorValue())
        })
    }
}

extension ObservableType where E: ResponseType & ResponseConvertible {
    public func mapThorValue() -> Observable<ThorValue> {
        return flatMap({ (response) -> Observable<ThorValue> in
            return Observable.just(try response.mapThorValue())
        })
    }
}
