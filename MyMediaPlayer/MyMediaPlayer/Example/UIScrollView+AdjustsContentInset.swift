//
//  UIScrollView+AdjustsContentInset.swift
//  MyMediaPlayer
//
//  Created by wuweixin on 2019/8/11.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit

//extension UIApplication {
//    override open var next: UIResponder? {
//        UITableView.awake
//        return super.next
//    }
//}

//extension UITableView {
//    static let awake: Void = {
//        swizzleMethods()
//    }()
//
//
//    fileprivate class func swizzleMethods() {
//        let m1 = class_getInstanceMethod(self, #selector(mm_layoutSubviews))!
//        let m2 = class_getInstanceMethod(self, #selector(layoutSubviews))!
//        method_exchangeImplementations(m1, m2)
//    }
//
//    @objc
//    func mm_layoutSubviews() {
//        print(NSStringFromClass(type(of: self)), "mm_layoutSubviews")
//        self.mm_layoutSubviews()
//    }
//}
