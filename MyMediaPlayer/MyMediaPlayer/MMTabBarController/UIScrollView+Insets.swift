//
//  UIScrollView+Insets.swift
//  MyMediaPlayer
//
//  Created by wuweixin on 2019/8/8.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit

internal struct AssociatedKeys {
    static var adjustedContentInsetBottom = "mm_adjustedContentInsetBottom"
    static var adjustedSafeAreaInsetBottom = "mm_adjustedSafeAreaInsetBottom"
    
    static var pendingPresentedViewController = "mm_pendingPresentedViewController"
    static var pendingPresentingViewController = "mm_pendingPresentingViewController"
}


extension UIScrollView {
    var hasSetAdjustedContentInsetBottom: Bool {
        return objc_getAssociatedObject(self, &AssociatedKeys.adjustedContentInsetBottom) as? NSNumber != nil
    }
    // iOS 11.0 以下
    var adjustedContentInsetBottom: CGFloat {
        get {
            if let number = objc_getAssociatedObject(self, &AssociatedKeys.adjustedContentInsetBottom) as? NSNumber {
                return CGFloat(number.floatValue)
            }
            return 0
        }
        set {
            let originInsetBottom = self.adjustedContentInsetBottom
            guard originInsetBottom != newValue else {
                return
            }
            
            var contentInsetBottom = self.contentInset.bottom
            contentInsetBottom -= originInsetBottom
            contentInsetBottom += newValue
            
            var scrollIndicatorInsetBottom = self.scrollIndicatorInsets.bottom
            scrollIndicatorInsetBottom -= originInsetBottom
            scrollIndicatorInsetBottom += newValue
            
            objc_setAssociatedObject(self, &AssociatedKeys.adjustedContentInsetBottom, NSNumber(value: Float(newValue)), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            self.contentInset.bottom = contentInsetBottom
            self.scrollIndicatorInsets.bottom = scrollIndicatorInsetBottom
        }
    }
}

extension UIViewController {
    @available(iOS 11.0, *)
    var adjustedSafeAreaInsetBottom: CGFloat {
        get {
            if let number = objc_getAssociatedObject(self, &AssociatedKeys.adjustedSafeAreaInsetBottom) as? NSNumber {
                return CGFloat(number.floatValue)
            }
            return 0
        }
        set {
            let originInsetBottom = self.adjustedSafeAreaInsetBottom
            guard originInsetBottom != newValue else {
                return
            }
            
            var insetBottom = self.additionalSafeAreaInsets.bottom
            insetBottom -= originInsetBottom
            insetBottom += newValue
            
            objc_setAssociatedObject(self, &AssociatedKeys.adjustedSafeAreaInsetBottom, NSNumber(value: Float(newValue)), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            self.additionalSafeAreaInsets.bottom = insetBottom
        }
    }
    
    func adjustsScrollViewInsets(bottom: CGFloat) {
        self.view.adjustedScrollViewInsets(in: self.view, bottomInset: bottom)
    }
}

fileprivate extension UIView {
    @discardableResult
    func adjustedScrollViewInsets(in root: UIView, bottomInset: CGFloat) -> Bool {
        let edge = root.bounds.maxY - self.convert(self.bounds, to: root).maxY
        
        let inset = bottomInset - edge
        if let scrollView = self as? UIScrollView {
            scrollView.adjustedContentInsetBottom = max(0, inset)
            return true
        }
        
        guard inset > 0 else {
            return false
        }
        
        for subview in subviews {
            if subview.adjustedScrollViewInsets(in: self, bottomInset: inset) {
                return true
            }
        }
        
        return false
    }
}
