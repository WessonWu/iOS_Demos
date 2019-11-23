//
//  内购监听
//  TestAppStore
//
//  Created by wuweixin on 2019/11/23.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import StoreKit

class InAppPurchasesObserver: NSObject, SKPaymentTransactionObserver {
    //Initialize the store observer.
    override init() {
        super.init()
        //Other initialization here.
    }

    //Observe transaction updates.
    func paymentQueue(_ queue: SKPaymentQueue,updatedTransactions transactions: [SKPaymentTransaction]) {
        //Handle transaction states here.
    }
}
