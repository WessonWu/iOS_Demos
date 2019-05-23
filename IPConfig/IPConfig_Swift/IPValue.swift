//
//  IPValue.swift
//  IPConfig_Swift
//
//  Created by wuweixin on 2019/5/23.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import Foundation

// Key = 接口名称+IP版本
public enum IPMapKey: RawRepresentable, Hashable, Equatable {
    case ipv4(String)
    case ipv6(String)
    
    public typealias RawValue = String
    public var rawValue: String {
        switch self {
        case .ipv4(let if_name):
            return "\(if_name)/ipv4"
        case .ipv6(let if_name):
            return "\(if_name)/ipv6"
        }
    }
    
    public init?(rawValue: String) {
        return nil
    }
    
    init?(sa_family: Int32, ifa_name: String?) {
        guard let name = ifa_name else { return nil }
        switch sa_family {
        case AF_INET:
            self = .ipv4(name)
        case AF_INET6:
            self = .ipv6(name)
        default:
            return nil
        }
    }
}

extension IPMapKey: CustomStringConvertible {
    public var description: String {
        return rawValue
    }
}

public enum IPValue {
    case ipv4(String)
    case ipv6(String)
    
    init?(sa_family: Int32, ifa_addr: String?) {
        guard let addr = ifa_addr else { return nil }
        switch sa_family {
        case AF_INET:
            self = .ipv4(addr)
        case AF_INET6:
            self = .ipv6(addr)
        default:
            return nil
        }
    }
}

extension IPValue: CustomStringConvertible {
    public var description: String {
        switch self {
        case .ipv4(let ip):
            return ip
        case .ipv6(let ip):
            return ip
        }
    }
}

public typealias IPMap = [IPMapKey: IPValue]
