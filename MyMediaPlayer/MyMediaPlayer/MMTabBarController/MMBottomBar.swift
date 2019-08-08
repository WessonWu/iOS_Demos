//
//  MMBottomBar.swift
//  MyMediaPlayer
//
//  Created by wuweixin on 2019/7/18.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit

public protocol MMToolBarDisplayble {
    var preferredToolBarHidden: Bool { get }
}

public extension MMToolBarDisplayble {
    var preferredToolBarHidden: Bool {
        return false
    }
}

public protocol MMTabBarDisplayble {
    var preferredTabBarHidden: Bool { get }
}

public extension MMTabBarDisplayble {
    var preferredTabBarHidden: Bool {
        return false
    }
}

open class MMBottomBar: UIView {
    open private(set) lazy var toolbar: MMToolBar = MMToolBar()
    open private(set) lazy var tabBar: MMTabBar = MMTabBar()
    
    public var isToolBarHidden: Bool = false
    public var isTabBarHidden: Bool = false
    
    public internal(set) var isTransitioning: Bool = false
    public var isUserInteractionEnabledWhenTransitioning: Bool = false
    
    public var isBottomBarHidden: Bool {
        return isToolBarHidden && isTabBarHidden
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInitialization()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInitialization()
    }
    
    private func commonInitialization() {
        self.backgroundColor = UIColor.clear
        self.addSubview(toolbar)
        self.addSubview(tabBar)
    }
    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard isTransitioning && !isUserInteractionEnabledWhenTransitioning else {
            return super.point(inside: point, with: event)
        }
        return false
    }
    
    open override func layoutSubviews() {
        let toolBarHeight: CGFloat = toolbar.minimumContentHeight
        let tabBarHeight: CGFloat = tabBar.minimumContentHeight
        let frameSize = self.frame.size
        var safeAreaBottom: CGFloat = 0
        if #available(iOS 11.0, *) {
            safeAreaBottom = self.safeAreaInsets.bottom
        }
        let toolBarFrame = CGRect(x: 0, y: 0, width: frameSize.width, height: toolBarHeight)
        let tabBarFrame = CGRect(x: 0, y: 0, width: frameSize.width, height: tabBarHeight + safeAreaBottom)
        switch (isToolBarHidden, isTabBarHidden) {
        case (false, false):
            toolbar.frame = toolBarFrame
            tabBar.frame = tabBarFrame.offsetBy(dx: 0, dy: toolBarFrame.maxY)
        case (false, true):
            toolbar.frame = self.bounds
            tabBar.frame = tabBarFrame.offsetBy(dx: 0, dy: frameSize.height)
        case (true, false):
            toolbar.frame = toolBarFrame.offsetBy(dx: 0, dy: frameSize.height)
            tabBar.frame = self.bounds
        case (true, true):
            toolbar.frame = toolBarFrame.offsetBy(dx: 0, dy: frameSize.height)
            tabBar.frame = tabBarFrame.offsetBy(dx: 0, dy: toolbar.frame.maxY)
        }
    }
    
    open func minimumContentHeight() -> CGFloat {
        var height: CGFloat = 0
        if !isToolBarHidden {
            height += toolbar.minimumContentHeight
        }
        
        if !isTabBarHidden {
            height += tabBar.minimumContentHeight
        }
        return height
    }
    
    
    func adjustsViewHiddens() {
        self.isHidden = self.isBottomBarHidden
        self.toolbar.isHidden = self.isToolBarHidden
        self.tabBar.isHidden = self.isTabBarHidden
    }
}
