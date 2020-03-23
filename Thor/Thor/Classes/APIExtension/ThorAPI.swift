import Foundation
import Moya
import Alamofire

public protocol ThorAPI: ThorTargetType {
    var url: URL { get }
    // 建议还是使用task，灵活性更强
    var parameters: [String: Any]? { get }
    
    // 约定合法的code(自动处理) 如果返回nil则自行处理
    var validCodes: Set<Int>? { get }
}

extension ThorAPI {
    public var task: Task {
        return Task.requestParameters(parameters: parameters ?? [:], encoding: URLEncoding.default)
    }
    
    public var parameters: [String: Any]? { return nil }
    public var validCodes: Set<Int>? { return nil }
    
    
    public var baseURL: URL {
        return url
    }
    
    public var path: String {
        return ""
    }
    
    public var sampleData: Data {
        return Data()
    }
    
    public var headers: [String : String]? {
        return SessionManager.defaultHTTPHeaders
    }
    
    public var method: Moya.Method {
        return .get
    }
    
    public var validationType: ValidationType {
        return .successCodes
    }
}
