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
    func fetch() -> [IPItem] {
        return IPConfig.getAllIPs().map { IPItem(title: $0.key.description, detail: $0.value.description) }
    }
}
