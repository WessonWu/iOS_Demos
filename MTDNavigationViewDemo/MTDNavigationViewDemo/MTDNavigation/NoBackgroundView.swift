//
//  NoBackgroundView.swift
//  MTDNavigationViewDemo
//
//  Created by wuweixin on 2019/8/5.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit

class NoBackgroundView: UIView {
    override var backgroundColor: UIColor? {
        get {
            return super.backgroundColor
        }
        set {
            // no background color
            super.backgroundColor = UIColor.clear
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInitilization()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInitilization()
    }
    
    func commonInitilization() {
        super.backgroundColor = UIColor.clear
    }
}
