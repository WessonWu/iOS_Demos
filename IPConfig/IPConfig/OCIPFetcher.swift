//
//  OCIPFetcher.swift
//  IPConfig
//
//  Created by wuweixin on 2019/5/23.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import Foundation


class OCIPFetcher: IPFetcher {
    var title: String? { return "OC版本" }
    func fetch() -> [IPItem] {
        return []
    }
}
