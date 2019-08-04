//
//  MTDViewControllerWrapperView.swift
//  MTDNavigationViewDemo
//
//  Created by wuweixin on 2019/8/4.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit

class MTDViewControllerWrapperView: UIView {
    var navigationView: MTDNavigationView?
    var contentView: UIView?
    
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
    
    private func commonInitilization() {
        super.backgroundColor = UIColor.clear
    }
    
    override func addSubview(_ view: UIView) {
        if let navigationView = view as? MTDNavigationView {
            self.navigationView = navigationView
        }
        super.addSubview(view)
    }
    
    override func willRemoveSubview(_ subview: UIView) {
        if subview == self.navigationView {
            self.navigationView = nil
        }
        super.willRemoveSubview(subview)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let statusBarHeight: CGFloat
        if #available(iOS 11.0, *) {
            statusBarHeight = max(20, self.safeAreaInsets.top)
        } else {
            statusBarHeight = 20
        }
        
        var contentViewFrame: CGRect = self.bounds
        if let navigationView = self.navigationView {
            let navigationViewFrame = CGRect(x: 0,
                                             y: 0,
                                             width: self.bounds.width,
                                             height: statusBarHeight + navigationView.contentHeight)
            if !navigationView.isHidden && !navigationView.isTranslucent {
                contentViewFrame = contentViewFrame.inset(by: UIEdgeInsets(top: navigationViewFrame.height,
                                                                           left: 0,
                                                                           bottom: 0,
                                                                           right: 0))
            }
            
            navigationView.frame = navigationViewFrame
        }
        
        if let contentView = self.contentView, contentView.superview == self {
            contentView.frame = contentViewFrame
        }
    }
}
