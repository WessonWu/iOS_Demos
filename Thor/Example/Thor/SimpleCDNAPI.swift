//
//  SimpleCDNAPI.swift
//  Thor_Example
//
//  Created by wuweixin on 2018/12/21.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Thor

struct SimpleCDNAPI: ThorAPI {
    var url: URL = URL(string: "http://dlstest.img4399.com/redirect/cdn.4399sj.com/test/ykd/common/ios/v1.0/startUp-hotTpl.html")!
    
    var needCache: Bool { return false }
}
