//
//  ToobarController.swift
//  ToolbarController
//
//  Created by wuweixin on 2019/7/9.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit

class ToolbarController: UITabBarController {
    
    internal private(set) var fakeTabBar: UITabBar?
    
    lazy var _controlBar: AudioControlBar = AudioControlBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.view.addSubview(_controlBar)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let bar = _controlBar
        var barHeight: CGFloat = bar.contentHeight
        let maxY: CGFloat
        if tabBar.isHidden {
            maxY = self.view.frame.height
            if #available(iOS 11.0, *) {
                barHeight += bar.contentHeight
            }
        } else {
            maxY = tabBar.frame.minY
        }
        
        bar.frame = CGRect(x: 0, y: maxY - barHeight, width: self.view.frame.width, height: barHeight)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if fakeTabBar == nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                guard self.fakeTabBar == nil else {
                    return
                }
                self.fakeTabBar = NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self.tabBar)) as? UITabBar
            }
        }
    }
}



typealias AnimationsWorkItem = (animations: () -> Void, completion: (Bool) -> Void)

extension UITabBarController {
    struct AssociatedKeys {
        static var isTabBarAnimating = "isTabBarAnimating"
        static var isTabBarHidden = "isTabBarHidden"
    }
    
    fileprivate var isTabBarAnimating: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.isTabBarAnimating) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.isTabBarAnimating, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    fileprivate var isTabBarHidden: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.isTabBarHidden) as? Bool ?? tabBar.isHidden
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.isTabBarHidden, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    
    var controlBar: AudioControlBar? {
        return (self as? ToolbarController)?._controlBar
    }
    
    func setTabBarHidden(_ hidden: Bool, animated: Bool) {
        guard let animationsWorkItem = self.tabBarAnimationsWorkItemWithHidden(hidden) else {
            return
        }
        
        if animated {
            UIView.animate(withDuration: 0.2,
                           delay: 0,
                           options: .curveEaseInOut,
                           animations: animationsWorkItem.animations,
                           completion: animationsWorkItem.completion)
        } else {
            animationsWorkItem.animations()
            animationsWorkItem.completion(true)
        }
    }
    
    func tabBarAnimationsWorkItemWithHidden(_ hidden: Bool) -> AnimationsWorkItem? {
        guard hidden != isTabBarHidden else {
            return nil
        }
        self.isTabBarHidden = hidden
        let tabBar = self.tabBar
        let snapshotView = tabBar.snapshotView(afterScreenUpdates: true)
        if let tempView = snapshotView {
            tempView.frame = tabBar.frame
            self.view.addSubview(tempView)
        }
        let startTransform: CGAffineTransform
        let endTransform: CGAffineTransform
        if hidden {
            startTransform = .identity
            endTransform = CGAffineTransform(translationX: 0, y: tabBar.frame.height)
        } else {
            startTransform = CGAffineTransform(translationX: 0, y: tabBar.frame.height)
            endTransform = .identity
        }
        if !isTabBarAnimating {
            snapshotView?.transform = startTransform
        }
        let animations: () -> Void =  {
            self.isTabBarAnimating = true
            snapshotView?.transform = endTransform
        }
        
        let completion: (Bool) -> Void = {(success) in
            snapshotView?.removeFromSuperview()
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            self.isTabBarAnimating = false
        }
        return (animations, completion)
    }
    
}
