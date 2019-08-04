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
        
        var contentFrame: CGRect = self.bounds
        if let navigationView = self.navigationView {
            let navigationHeight = statusBarHeight + navigationView.contentHeight
            
            let navigationFrame: CGRect
            if navigationView.isNavigationViewHidden {
                navigationFrame = CGRect(x: 0, y: -navigationHeight, width: self.bounds.width, height: navigationHeight)
            } else {
                navigationFrame = CGRect(x: 0, y: 0, width: self.bounds.width, height: navigationHeight)
                if !navigationView.isTranslucent {
                    contentFrame = contentFrame.inset(by: UIEdgeInsets(top: navigationHeight, left: 0, bottom: 0, right: 0))
                }
            }
            
            navigationView.frame = navigationFrame
        }
        
        if let contentView = self.contentView, contentView.superview == self {
            contentView.frame = contentFrame
        }
    }
    
    func setNavigationViewHidden(_ hidden: Bool, animated: Bool) {
        self.layoutIfNeeded()
        guard let navigationView = self.navigationView else {
            return
        }
        if animated {
            self.setNeedsLayout()
            navigationView.setNavigationViewHidden(hidden, animations: {
                self.layoutIfNeeded()
            }, completion: { (_) in
//                self.setNeedsLayout()
//                self.layoutIfNeeded()
            })
        } else {
            navigationView.setNavigationViewHidden(hidden)
        }
    }
}
