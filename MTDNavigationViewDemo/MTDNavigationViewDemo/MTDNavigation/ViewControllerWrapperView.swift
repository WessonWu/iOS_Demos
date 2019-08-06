//
//  ViewControllerWrapperView.swift
//  MTDNavigationViewDemo
//
//  Created by wuweixin on 2019/8/4.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit

final class ViewControllerWrapperView: NoBackgroundView {
    var navigationView: MTDNavigationView?
    weak var contentViewController: UIViewController?
    
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
                    if let vc = self.contentViewController,
                        !vc.extendedLayoutIncludesOpaqueBars || vc.edgesForExtendedLayout.contains(.top) {
                        contentFrame = contentFrame.inset(by: UIEdgeInsets(top: navigationHeight, left: 0, bottom: 0, right: 0))
                    }
                }
            }
            
            navigationView.frame = navigationFrame
        }
        
        if let vc = self.contentViewController, let contentView = vc.view, contentView.superview == self {
            contentView.frame = contentFrame
        }
    }
    
    func setNavigationViewHidden(_ hidden: Bool, animated: Bool) {
        self.layoutIfNeeded()
        guard let navigationView = self.navigationView else {
            return
        }
        var animations: (() -> Void)? = nil
        if animated {
            self.setNeedsLayout()
            animations = {
                self.layoutIfNeeded()
            }
        }
        let completion: (Bool) -> Void = { _ in
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
        navigationView.setNavigationViewHidden(hidden, animations: animations, completion: completion)
    }
}
