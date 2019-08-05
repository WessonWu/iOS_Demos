//
//  UIScrollView+Insets.swift
//  MTDNavigationViewDemo
//
//  Created by wuweixin on 2019/8/5.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit

fileprivate var MTDWrapperController_adjustedContentInsetTop: UInt8 = 0

extension UIScrollView {
    var hasSetAdjustedContentInsetTop: Bool {
        return objc_getAssociatedObject(self, &MTDWrapperController_adjustedContentInsetTop) as? CGFloat != nil
    }
    // iOS 11.0 以下
    var adjustedContentInsetTop: CGFloat {
        get {
            return objc_getAssociatedObject(self, &MTDWrapperController_adjustedContentInsetTop) as? CGFloat ?? 0
        }
        set {
            let originInsetTop = self.adjustedContentInsetTop
            guard originInsetTop != newValue else {
                return
            }
            
            let hasSetAdjustedContentInsetTop = self.hasSetAdjustedContentInsetTop
            
            var contentInsetTop = self.contentInset.top
            contentInsetTop -= originInsetTop
            contentInsetTop += newValue
            
            var scrollIndicatorInsetTop = self.scrollIndicatorInsets.top
            scrollIndicatorInsetTop -= originInsetTop
            scrollIndicatorInsetTop += newValue
            
            objc_setAssociatedObject(self, &MTDWrapperController_adjustedContentInsetTop, newValue, .OBJC_ASSOCIATION_ASSIGN)
            self.contentInset.top = contentInsetTop
            self.scrollIndicatorInsets.top = scrollIndicatorInsetTop
            
            if !hasSetAdjustedContentInsetTop {
                self.contentOffset.y = -contentInsetTop
            }
        }
    }
}

extension UIViewController {
    func adjustsScrollViewInsets(top: CGFloat) {
        if let scrollView = self.view as? UIScrollView {
            scrollView.adjustedContentInsetTop = top
            return
        }
        
        for subview in self.view.subviews {
            if let scrollView = subview as? UIScrollView {
                scrollView.adjustedContentInsetTop = top
                break
            }
        }
    }
}
