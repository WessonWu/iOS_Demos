//
//  MiniPlayerSongBar.swift
//  MyMediaPlayer
//
//  Created by wuweixin on 2019/7/18.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit

public class MiniPlayerSongView: UIView {
    public var minimumContentHeight: CGFloat = 48
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInitialization()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInitialization()
    }
    
    
    private func commonInitialization() {
        self.backgroundColor = UIColor.orange
    }
}
