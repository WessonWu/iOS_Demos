//
//  StickyHeaderViewBinder.swift
//  StickyHeaderViewDemo
//
//  Created by wuweixin on 2019/8/11.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit

public final class StickyHeaderViewBinder: NSObject {
    public typealias ScrollUpwardCallback = (CGFloat) -> Void
    
    public private(set) weak var scrollView: UIScrollView?
    public private(set) weak var headerView: UIView?
    
    /// 用于设置HeaderView的高度，但是≠headerView的高度(可能包括状态栏的高度)
    /// headerViewHeight = contentInset.top + additionalHeightForHeaderView
    public let contentInsetTopForHeaderView: CGFloat
    /// 额外的高度，用于制造视差效果
    public let additionalHeightForHeaderView: CGFloat
    
    /// headerView在contentOffsetY = [-headerViewHeight, -scrollUpwardEdgeInsetTop]区间内滚动（计算滚动区间比例）
    /// scrollUpwardEdgeInsetTop一般是用于渐变导航栏背景
    public var scrollUpwardEdgeInsetTop: CGFloat = 0
    public private(set) var scrollUpwardCallback: ScrollUpwardCallback?
    
    var obserer: NSKeyValueObservation?
    
    public init(contentInsetTopForHeaderView: CGFloat, additionalHeightForHeaderView: CGFloat = 0) {
        self.contentInsetTopForHeaderView = contentInsetTopForHeaderView
        self.additionalHeightForHeaderView = additionalHeightForHeaderView
    }
    
    public func bind(_ scrollView: UIScrollView, headerView: UIView, callback: ScrollUpwardCallback? = nil) {
        removeObserverIfNeeded()
        self.scrollUpwardCallback = callback
        
        self.scrollView = scrollView
        self.headerView = headerView
        var top = scrollView.contentInset.top
        top += self.contentInsetTopForHeaderView
        scrollView.contentInset.top = top
        
        headerView.frame = CGRect(x: 0, y: 0, width: scrollView.frame.width, height: top)
        headerView.layer.zPosition = -1000
        scrollView.insertSubview(headerView, at: 0)
        
        self.obserer = scrollView.observe(\.contentOffset, changeHandler: { [weak self] (scrollView, _) in
            self?.scrollViewDidScroll(scrollView)
        })
    }
    
    public func unbind() {
        self.scrollUpwardCallback = nil
        removeObserverIfNeeded()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let stickyHeaderView = self.headerView else {
            return
        }
        // scrollDidScroll
        let contentOffsetY = scrollView.contentOffset.y
        let stickyHeight: CGFloat
        if #available(iOS 11.0, *) {
            stickyHeight = scrollView.adjustedContentInset.top
        } else {
            stickyHeight = scrollView.contentInset.top
        }
        
        let originY = min(contentOffsetY, -stickyHeight)
        let height = max(-contentOffsetY, stickyHeight)
        stickyHeaderView.frame = CGRect(x: 0,
                                        y: originY,
                                        width: scrollView.frame.width,
                                        height: height + additionalHeightForHeaderView)
        guard let callback = self.scrollUpwardCallback else {
            return
        }
        let percent: CGFloat
        if contentOffsetY <= -stickyHeight {
            percent = 0
        } else if contentOffsetY >= -scrollUpwardEdgeInsetTop {
            percent = 1
        } else {
            percent = (contentOffsetY + stickyHeight) / (stickyHeight - scrollUpwardEdgeInsetTop)
        }
        callback(percent)
    }
    
    func removeObserverIfNeeded() {
        if let observer = self.obserer {
            observer.invalidate()
            self.obserer = nil
        }
    }
    
    deinit {
        unbind()
        
        #if DEBUG
        print(#file, #function)
        #endif
    }
}
