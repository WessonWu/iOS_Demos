//
//  IPConfig.swift
//  IPConfig_Swift
//
//  Created by wuweixin on 2019/5/23.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import Foundation

public class IPConfig {
    public static let Wifi = "en0"
    public static let Cellular = "pdp_ip0"
    public static let VPN = "utun0"
    
    public class func getAllIPs() -> IPMap {
        var ips: IPMap = [:]
        var interfaces: UnsafeMutablePointer<ifaddrs>? = nil
        defer {
            if interfaces != nil {
                free(interfaces)
            }
        }
        
        guard getifaddrs(&interfaces) == 0 else { return ips }
        var temp_interface: UnsafeMutablePointer<ifaddrs>? = interfaces
        while let interface = temp_interface {
            if let ifa_addr = interface.pointee.ifa_addr?.pointee {
                let sa_family = Int32(ifa_addr.sa_family)
                let ifa_name = String(cString: interface.pointee.ifa_name, encoding: .utf8)
                if let key = IPMapKey(sa_family: sa_family, ifa_name: ifa_name) {
                    let len_t = max(INET_ADDRSTRLEN, INET6_ADDRSTRLEN)
                    var inaddr = unsafeBitCast(ifa_addr, to: sockaddr_in.self).sin_addr
                    var buffer = [CChar](repeating: 0, count: Int(len_t))
                    inet_ntop(sa_family, UnsafeRawPointer(&inaddr), &buffer, UInt32(len_t))
                    let addr = String(cString: buffer, encoding: .utf8)
                    ips[key] = IPValue(sa_family: sa_family, ifa_addr: addr)
                }
            }
            temp_interface = interface.pointee.ifa_next
        }
        return ips
    }
    
    public class func getIPWithKey(_ key: IPMapKey) -> IPValue? {
        return getAllIPs()[key]
    }
}
