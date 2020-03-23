import Foundation


public protocol ThorPagingAPI: AnyObject, ThorAPI {
    /// 可以使用内置的PagingParams，也可以自己定义
    var paging: PagingParamsCompatible { get set }
    
    func resetPaging()
}

public extension ThorPagingAPI {
    var parameters: [String : Any]? {
        return defaultPagingParams
    }
    
    // 实现的类要加上该参数，或自己实现
    var defaultPagingParams: [String: Any] {
        return ["startKey": paging.startKey]
    }
    
    func resetPaging() {
        paging.reset()
    }
}
