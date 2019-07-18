//
//  MMBottomBar.swift
//  MyMediaPlayer
//
//  Created by wuweixin on 2019/7/18.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit

public class MMBottomBar: UIView {
    public private(set) lazy var songView: MiniPlayerSongView = MiniPlayerSongView()
    public private(set) lazy var tabBar: MMTabBar = MMTabBar()
    
    public var isSongViewHidden: Bool = false
    public var isTabBarHidden: Bool = false
    
    public var isBottomBarHidden: Bool {
        return isSongViewHidden && isTabBarHidden
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
        self.addSubview(songView)
        self.addSubview(tabBar)
    }
    
    public override func layoutSubviews() {
        let songViewHeight: CGFloat = songView.minimumContentHeight
        let tabBarHeight: CGFloat = tabBar.minimumContentHeight
        let frameSize = self.frame.size
        var safeAreaBottom: CGFloat = 0
        if #available(iOS 11.0, *) {
            safeAreaBottom = self.safeAreaInsets.bottom
        }
        let songViewFrame = CGRect(x: 0, y: 0, width: frameSize.width, height: songViewHeight)
        let tabBarFrame = CGRect(x: 0, y: 0, width: frameSize.width, height: tabBarHeight + safeAreaBottom)
        switch (isSongViewHidden, isTabBarHidden) {
        case (false, false):
            songView.frame = songViewFrame
            tabBar.frame = tabBarFrame.offsetBy(dx: 0, dy: songViewFrame.maxY)
        case (false, true):
            songView.frame = self.bounds
            tabBar.frame = tabBarFrame.offsetBy(dx: 0, dy: frameSize.height)
        case (true, false):
            songView.frame = songViewFrame.offsetBy(dx: 0, dy: -songViewHeight)
            tabBar.frame = self.bounds
        case (true, true):
            songView.frame = songViewFrame.offsetBy(dx: 0, dy: frameSize.height)
            tabBar.frame = tabBarFrame.offsetBy(dx: 0, dy: songView.frame.maxY)
        }
    }
    
    public func minimumContentHeight() -> CGFloat {
        var height: CGFloat = 0
        if !isSongViewHidden {
            height += songView.minimumContentHeight
        }
        
        if !isTabBarHidden {
            height += tabBar.minimumContentHeight
        }
        return height
    }
}
