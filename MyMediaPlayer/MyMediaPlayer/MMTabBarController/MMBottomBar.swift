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
    
    public var isAllHidden: Bool {
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
        tabBar.automaticallyAdjustsContentInsets = false
        self.backgroundColor = UIColor.white
        self.addSubview(songView)
        self.addSubview(tabBar)
    }
    
    public override func layoutSubviews() {
        let frameSize = self.frame.size
        let songViewHeight: CGFloat = songView.intrinsicHeight
        let tabBarHeight: CGFloat = tabBar.itemHeight
        if isSongViewHidden {
            songView.frame = CGRect(x: 0, y: frameSize.height, width: frameSize.width, height: songViewHeight)
        } else {
            songView.frame = CGRect(x: 0, y: 0, width: frameSize.width, height: songViewHeight)
        }
        if isTabBarHidden && !isSongViewHidden {
            tabBar.frame = CGRect(x: 0, y: frameSize.height, width: frameSize.width, height: tabBarHeight)
        } else if !isSongViewHidden {
            tabBar.frame = CGRect(x: 0, y: songView.frame.maxY, width: frameSize.width, height: tabBarHeight)
        }
    }
    
    public func minimumContentHeight() -> CGFloat {
        var height: CGFloat = 0
        if !isSongViewHidden {
            height += songView.intrinsicHeight
        }
        
        if !isTabBarHidden {
            height += tabBar.itemHeight
        }
        return height
    }
}
