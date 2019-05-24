//
//  OCIPFetcher.swift
//  IPConfig
//
//  Created by wuweixin on 2019/5/23.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import Foundation
import IPConfig_OC

class OCIPFetcher: IPFetcher {
    var title: String? { return "OC版本" }
    var text: String?
    func fetch() -> [IPItem] {
        let ips = WXIPConfig.getAllIPs()
        let wifi_ipv4 = ips[WXIPConfig.key(withName: kWXConfigInterfaceWifi, version: kWXIPConfigIPV4)].stringValue
        let wifi_ipv6 = ips[WXIPConfig.key(withName: kWXConfigInterfaceWifi, version: kWXIPConfigIPV6)].stringValue
        let cellular_ipv4 = ips[WXIPConfig.key(withName: kWXConfigInterfaceCellular, version: kWXIPConfigIPV4)].stringValue
        let cellular_ipv6 = ips[WXIPConfig.key(withName: kWXConfigInterfaceCellular, version: kWXIPConfigIPV6)].stringValue
        let vpn_ipv4 = ips[WXIPConfig.key(withName: kWXConfigInterfaceVPN, version: kWXIPConfigIPV4)].stringValue
        let vpn_ipv6 = ips[WXIPConfig.key(withName: kWXConfigInterfaceVPN, version: kWXIPConfigIPV6)].stringValue
        self.text = """
        wifi/ipv4: \(wifi_ipv4)
        wifi/ipv6: \(wifi_ipv6)
        cellular/ipv4: \(cellular_ipv4)
        cellular/ipv6: \(cellular_ipv6)
        vpn/ipv4: \(vpn_ipv4)
        vpn/ipv6: \(vpn_ipv6)
        """
        return ips.map { IPItem(title: $0.key.description, detail: $0.value) }
    }
}


fileprivate extension Optional where Wrapped == String {
    var stringValue: String {
        switch self {
        case .none: return "null"
        case .some(let value): return value
        }
    }
}
