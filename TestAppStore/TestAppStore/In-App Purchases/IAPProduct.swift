//
//  IAPProduct.swift
//  TestAppStore
//
//  Created by wuweixin on 2019/11/23.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import Foundation

enum IAPProduct: String, CaseIterable {
    case coin_6t = "cn.wessonwu.app.TestAppStore.consumable.6t" // consumable
    case pigPecs = "cn.wessonwu.app.TestAppStore.topics.PigPecs" // no consumable
    case vip = "cn.wessonwu.app.TestAppStore.vip.primary" // auto-renewable subscription
    case video_vip = "cn.wessonwu.app.TestAppStore.vip.video" // no renewable subscription
}
