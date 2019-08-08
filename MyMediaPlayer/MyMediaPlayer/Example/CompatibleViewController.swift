//
//  CompatibleViewController.swift
//  MyMediaPlayer
//
//  Created by wuweixin on 2019/8/8.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit

class CompatibleViewController: UIViewController {

    open override var shouldAutorotate: Bool{
        if UIDevice.isPad { return true }
        return false
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        if UIDevice.isPad { return super.supportedInterfaceOrientations }
        return .portrait
    }
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        if UIDevice.isPad { return super.preferredInterfaceOrientationForPresentation }
        return .portrait
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

}

extension UIDevice {
    static let isPad = UIDevice.current.userInterfaceIdiom == .pad
    func rotate(with orientation: UIDeviceOrientation) {
        UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
    }
}
