import Foundation
import RxSwift

public extension Reactive where Base == AnyThorProvider {
    func thorRequest(_ target: ThorAPI, callbackQueue: DispatchQueue? = nil) -> Single<ThorResponse> {
        return Single.create { [weak base] single in
            let cancellableToken = base?.thorRequest(target, callbackQueue: callbackQueue, progress: nil) { result in
                switch result {
                case let .success(response):
                    single(.success(response))
                case let .failure(error):
                    single(.error(error))
                }
            }
            
            return Disposables.create {
                cancellableToken?.cancel()
            }
        }
    }
    
    func thorPagingRequest(_ target: ThorPagingAPI, callbackQueue: DispatchQueue? = nil) -> Single<ThorResponse> {
        return Single.create { [weak base] single in
            let cancellableToken = base?.thorPagingRequest(target, callbackQueue: callbackQueue, progress: nil) { result in
                switch result {
                case let .success(response):
                    single(.success(response))
                case let .failure(error):
                    single(.error(error))
                }
            }
            
            return Disposables.create {
                cancellableToken?.cancel()
            }
        }
    }
}
