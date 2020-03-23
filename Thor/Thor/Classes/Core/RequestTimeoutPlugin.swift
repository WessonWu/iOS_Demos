import Foundation
import Moya

open class RequestTimeoutPlugin: PluginType {
    open func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var result = request
        if let timeoutable = target as? RequestTimeoutable, timeoutable.timeoutInterval > 0 {
            result.timeoutInterval = timeoutable.timeoutInterval
        }
        return result
    }
}
