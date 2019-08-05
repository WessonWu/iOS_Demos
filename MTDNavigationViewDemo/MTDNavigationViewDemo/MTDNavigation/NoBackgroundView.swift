//
//  NoBackgroundView.swift
//  MTDNavigationViewDemo
//
//  Created by wuweixin on 2019/8/5.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit

open class NoBackgroundView: UIView {
    open override var backgroundColor: UIColor? {
        get {
            return super.backgroundColor
        }
        set {
            // no background color
            super.backgroundColor = UIColor.clear
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInitilization()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInitilization()
    }
    
    func commonInitilization() {
        super.backgroundColor = UIColor.clear
    }
}
