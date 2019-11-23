//
//  IAPService.swift
//  TestAppStore
//
//  Created by wuweixin on 2019/11/23.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import Foundation
import StoreKit

class IAPService: NSObject {
    
    static let shared = IAPService()
    private override init() {
        super.init()
    }
    
    func getProducts() {
        let identifiers = IAPProduct.allCases.map { $0.rawValue }
        let productIdentifiers = Set<String>.init(identifiers)
        let request = SKProductsRequest(productIdentifiers: productIdentifiers)
        request.delegate = self
        request.start()
    }
}

extension IAPService: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        for product in response.products {
            print(product.localizedTitle)
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print(error)
    }
}
