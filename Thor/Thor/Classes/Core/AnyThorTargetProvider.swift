import Foundation
import Moya

open class AnyThorTargetProvider: Moya.MoyaProvider<AnyThorTarget> {
    public override init(endpointClosure: @escaping MoyaProvider<Target>.EndpointClosure = MoyaProvider<Target>.defaultEndpointMapping,
                         requestClosure: @escaping MoyaProvider<Target>.RequestClosure =  MoyaProvider<Target>.defaultRequestMapping,
                         stubClosure: @escaping MoyaProvider<Target>.StubClosure = MoyaProvider.neverStub,
                         callbackQueue: DispatchQueue? = nil,
                         manager: Manager = MoyaProvider<Target>.defaultAlamofireManager(),
                         plugins: [PluginType] = AnyThorTargetProvider.defaultPlugins,
                         trackInflights: Bool = false) {
        super.init(
            endpointClosure: endpointClosure,
            requestClosure: requestClosure,
            stubClosure: stubClosure,
            callbackQueue: callbackQueue,
            manager: manager,
            plugins: plugins,
            trackInflights: trackInflights
        )
    }
    
    public class var defaultPlugins: [PluginType] {
        return [RequestTimeoutPlugin(), RequestCachePlugin()]
    }
}
