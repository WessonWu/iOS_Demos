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

public class MMBottomBar: UIView {
    public private(set) lazy var toolBar: MMToolBar = MMToolBar()
    public private(set) lazy var tabBar: MMTabBar = MMTabBar()
    
    public var isToolBarHidden: Bool = false
    public var isTabBarHidden: Bool = false
    
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
        self.backgroundColor = UIColor.white
        self.addSubview(toolBar)
        self.addSubview(tabBar)
    }
    
    public override func layoutSubviews() {
        let toolBarHeight: CGFloat = toolBar.minimumContentHeight
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
            toolBar.frame = toolBarFrame
            tabBar.frame = tabBarFrame.offsetBy(dx: 0, dy: toolBarFrame.maxY)
        case (false, true):
            toolBar.frame = self.bounds
            tabBar.frame = tabBarFrame.offsetBy(dx: 0, dy: frameSize.height)
        case (true, false):
            toolBar.frame = toolBarFrame.offsetBy(dx: 0, dy: frameSize.height)
            tabBar.frame = self.bounds
        case (true, true):
            toolBar.frame = toolBarFrame.offsetBy(dx: 0, dy: frameSize.height)
            tabBar.frame = tabBarFrame.offsetBy(dx: 0, dy: toolBar.frame.maxY)
        }
    }
    
    public func minimumContentHeight() -> CGFloat {
        var height: CGFloat = 0
        if !isToolBarHidden {
            height += toolBar.minimumContentHeight
        }
        
        if !isTabBarHidden {
            height += tabBar.minimumContentHeight
        }
        return height
    }
    
    
    func adjustsViewHiddens() {
        self.isHidden = self.isBottomBarHidden
        self.toolBar.isHidden = self.isToolBarHidden
        self.tabBar.isHidden = self.isTabBarHidden
    }
}
