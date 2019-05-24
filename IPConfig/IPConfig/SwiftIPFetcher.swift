//
//  SwiftIPFetcher.swift
//  IPConfig
//
//  Created by wuweixin on 2019/5/23.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import IPConfig_Swift

class SwiftIPFetcher: IPFetcher {
    var title: String? { return "Swift版本" }
    var text: String?
    func fetch() -> [IPItem] {
        let ips = IPConfig.getAllIPs()
        let wifi_ipv4 = ips[.ipv4(IPConfig.Wifi)].stringValue
        let wifi_ipv6 = ips[.ipv6(IPConfig.Wifi)].stringValue
        let cellular_ipv4 = ips[.ipv4(IPConfig.Cellular)].stringValue
        let cellular_ipv6 = ips[.ipv6(IPConfig.Cellular)].stringValue
        let vpn_ipv4 = ips[.ipv4(IPConfig.VPN)].stringValue
        let vpn_ipv6 = ips[.ipv6(IPConfig.VPN)].stringValue
        self.text = """
        wifi/ipv4: \(wifi_ipv4)
        wifi/ipv6: \(wifi_ipv6)
        cellular/ipv4: \(cellular_ipv4)
        cellular/ipv6: \(cellular_ipv6)
        vpn/ipv4: \(vpn_ipv4)
        vpn/ipv6: \(vpn_ipv6)
        """
        return ips.map { IPItem(title: $0.key.description, detail: $0.value.description) }
    }
}


fileprivate extension Optional where Wrapped == IPValue {
    var stringValue: String {
        switch self {
        case .none: return "null"
        case .some(let value): return value.description
        }
    }
}
