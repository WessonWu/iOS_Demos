//
//  MMNavigationStackView.swift
//  MyMediaPlayer
//
//  Created by wuweixin on 2019/7/20.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit

class MMNavigationStackView: UIView {
    
    override func layoutSubviews() {
        subviews.forEach {
            $0.frame = self.bounds
        }
    }
}
