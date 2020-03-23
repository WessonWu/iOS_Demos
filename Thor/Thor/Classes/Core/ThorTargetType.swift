import Foundation
import Moya

public protocol ThorTargetType: Moya.TargetType, RequestTimeoutable, RequestCacheable {}


