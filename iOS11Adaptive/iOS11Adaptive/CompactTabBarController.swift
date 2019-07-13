//
//  CompactTabBarController.swift
//  iOS11Adaptive
//
//  Created by wuweixin on 2019/7/13.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit


/// 录屏：
/// 在终端输入命令：xcrun simctl io booted recordVideo --type=mp4 myRecord.mp4
/// 结束录屏：Control+C

@available(iOS 11.0, *)
final class CompactTabBar: UITabBar {
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        
        set {
            /// Fix iPhoneX_iOS11.0_bug01 (push时tabBar上移问题)
            var newFrame = newValue
            /// Check if iPhoneX series
            if let superview = self.superview, superview.safeAreaInsets.bottom > 0 {
                let fixedOriginY = superview.frame.size.height - newFrame.height
                if newFrame.origin.y < fixedOriginY {
                    newFrame.origin.y = fixedOriginY
                }
            }
            
            super.frame = newFrame
        }
    }
    
    
    /// Fix iPhoneX_iOS11.0_bug02 (先present在push时，会出现先tabBar高度变矮，再恢复正常)
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        guard let bottomInset = self.superview?.safeAreaInsets.bottom else { return sizeThatFits }
        if bottomInset > 0 && sizeThatFits.height < 50 && (sizeThatFits.height + bottomInset < 90) {
            sizeThatFits.height += bottomInset
        }
        return sizeThatFits
    }
}

final class CompactTabBarController: UITabBarController {
    
    override func loadView() {
        super.loadView()
        
        if #available(iOS 11.0, *) {
            self.setValue(CompactTabBar(), forKey: "tabBar")
        }
    }
    
    
    override var shouldAutorotate: Bool {
        return selectedViewController?.shouldAutorotate ?? super.shouldAutorotate
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return selectedViewController?.supportedInterfaceOrientations ?? super.supportedInterfaceOrientations
    }
    
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return selectedViewController?.preferredInterfaceOrientationForPresentation ?? super.preferredInterfaceOrientationForPresentation
    }
}
