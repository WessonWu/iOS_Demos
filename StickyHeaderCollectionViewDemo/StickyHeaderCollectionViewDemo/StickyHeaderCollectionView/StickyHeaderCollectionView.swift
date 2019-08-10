//
//  StickyHeaderCollectionView.swift
//  StickyHeaderCollectionViewDemo
//
//  Created by wuweixin on 2019/8/10.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit

open class StickyHeaderCollectionView: UICollectionView {
    public typealias StickyHeaderScrollUpwardPercentCallback = (CGFloat) -> Void
    /// 头部粘性视图
    open var headerView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let headerView = self.headerView {
                self.addSubview(headerView)
            }
            addObserver(for: self.headerView, inAttachedWindow: self.window)
        }
    }
    
    /// 用于设置HeaderView的高度，但是≠headerView的高度(可能包括状态栏的高度)
    open var contentInsetTopForHeaderView: CGFloat = 0 {
        didSet {
            var top = self.contentInset.top
            top -= oldValue
            top += self.contentInsetTopForHeaderView
            self.contentInset.top = top
        }
    }
    
    /// headerView在contentOffsetY = [-headerViewHeight, -scrollUpwardEdgeInsetTop]区间内滚动（计算滚动区间比例）
    /// scrollUpwardEdgeInsetTop一般是用于渐变导航栏背景
    open var scrollUpwardEdgeInsetTop: CGFloat = 0
    open var scrollUpwardPercentCallback: StickyHeaderScrollUpwardPercentCallback?
    
    var contentOffsetObserver: NSKeyValueObservation?
    
    open override func willMove(toWindow newWindow: UIWindow?) {
        addObserver(for: self.headerView, inAttachedWindow: newWindow)
        super.willMove(toWindow: newWindow)
    }
    
    open func scrollViewDidScrollWhenHeaderViewExist(_ scrollView: UIScrollView, with stickyHeaderView: UIView) {
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
                                        height: height)
        guard let callback = self.scrollUpwardPercentCallback else {
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
    
    func addObserver(for stickyHeaderView: UIView?, inAttachedWindow window: UIWindow?) {
        removeObserverIfNeeded()
        if window != nil, let stickyHeaderView = stickyHeaderView {
            self.scrollViewDidScrollWhenHeaderViewExist(self, with: stickyHeaderView)
            self.contentOffsetObserver = self.observe(\.contentOffset, changeHandler: { (scrollView, _) in
                self.scrollViewDidScrollWhenHeaderViewExist(scrollView, with: stickyHeaderView)
            })
        }
    }
    
    func removeObserverIfNeeded() {
        if let observer = self.contentOffsetObserver {
            observer.invalidate()
            self.contentOffsetObserver = nil
        }
    }
    
    deinit {
        removeObserverIfNeeded()
    }

}
