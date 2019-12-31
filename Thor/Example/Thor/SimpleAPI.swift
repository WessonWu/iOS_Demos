//
//  SimpleAPI.swift
//  Thor_Example
//
//  Created by zhengxu on 2018/5/25.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import Foundation
import Thor

class SimpleAPI: ThorPagingAPI {
    var paging: PagingParamsCompatible = PagingParams()
    
    var url: URL
    
    var needCache: Bool {
        return true
    }
    var timeoutInterval: TimeInterval {
        return 5
    }
    
    var validCodes: Set<Int>? {
//        return [200]
        return [100]
    }
    
    init() {
        url = URL(string: "http://mobi.4399tech.com/redirect/tuer/testapi/app/iphone/v1.0/special/list.html")!;
    }
}
