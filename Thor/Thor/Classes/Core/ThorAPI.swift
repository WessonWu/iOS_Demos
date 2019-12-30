//
//  ThorAPI.swift
//  Thor
//
//  Created by wuweixin on 2019/12/30.
//

import Foundation
import Moya

public protocol ThorAPI: ThorTargetType, Timeoutable, Cacheable {
    // 建议还是使用task，灵活性更强
    var parameters: [String: Any]? { get }
    
    // 约定合法的code(自动处理) 如果返回nil则自行处理
    var validCodes: Set<Int>? { get }
}

public extension ThorAPI {
    var task: Task {
        return Task.requestParameters(parameters: parameters ?? [:], encoding: URLEncoding.default)
    }
    
    var headers : [String : String]? {
        get {
            let acceptEncoding: String = "gzip;q=1.0, compress;q=0.5"
            
            let acceptLanguage = Locale.preferredLanguages.prefix(6).enumerated().map { index, languageCode in
                let quality = 1.0 - (Double(index) * 0.1)
                return "\(languageCode);q=\(quality)"
                }.joined(separator: ", ")
            
            // Example: `ThorExample/1.0 (com.4399.thor; build:1; iOS 10.0.0) Thor/0.1.0`
            let userAgent: String = {
                if let info = Bundle.main.infoDictionary {
                    let executable = info[kCFBundleExecutableKey as String] as? String ?? "Unknown"
                    let bundle = info[kCFBundleIdentifierKey as String] as? String ?? "Unknown"
                    let appVersion = info["CFBundleShortVersionString"] as? String ?? "Unknown"
                    let appBuild = info[kCFBundleVersionKey as String] as? String ?? "Unknown"
                    
                    let osNameVersion: String = {
                        let version = ProcessInfo.processInfo.operatingSystemVersion
                        let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
                        
                        let osName: String = {
                            #if os(iOS)
                            return "iOS"
                            #elseif os(watchOS)
                            return "watchOS"
                            #elseif os(tvOS)
                            return "tvOS"
                            #elseif os(macOS)
                            return "OS X"
                            #elseif os(Linux)
                            return "Linux"
                            #else
                            return "Unknown"
                            #endif
                        }()
                        
                        return "\(osName) \(versionString)"
                    }()
                    
                    let alamofireVersion: String = {
                        guard
                            let afInfo = Bundle(for: Manager.self).infoDictionary,
                            let build = afInfo["CFBundleShortVersionString"]
                            else { return "Unknown" }
                        
                        return "Thor/\(build)"
                    }()
                    
                    return "\(executable)/\(appVersion) (\(bundle); build:\(appBuild); \(osNameVersion)) \(alamofireVersion)"
                }
                
                return "Alamofire"
            }()
            
            return [
                "Accept-Encoding": acceptEncoding,
                "Accept-Language": acceptLanguage,
                "User-Agent": userAgent
            ]
        }
    }
    
    var parameters: [String: Any]? { return nil }
    var validCodes: Set<Int>? { return nil }
}
