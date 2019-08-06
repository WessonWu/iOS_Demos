//
//  MTDNavigationItemView.swift
//  MTDNavigationViewDemo
//
//  Created by wuweixin on 2019/8/3.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit

open class MTDImageItemView: ImageButton {
    open override var intrinsicContentSize: CGSize {
        return CGSize(width: 32, height: MTDNavigationManager.style.contentHeight)
    }
}

open class MTDTitleItemView: TitleButton {
    override func commonInitilization() {
        super.commonInitilization()
        self.contentEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    }
    
    open override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width, height: MTDNavigationManager.style.contentHeight)
    }
}

open class MTDSpacingItemView: NoBackgroundView {
    open var spacing: CGFloat = 0
    open override var intrinsicContentSize: CGSize {
        return CGSize(width: spacing, height: 1)
    }
    
    public convenience init(spacing: CGFloat) {
        self.init()
        self.spacing = spacing
    }
    
    override func commonInitilization() {
        super.commonInitilization()
        
        self.isUserInteractionEnabled = false
    }
}
