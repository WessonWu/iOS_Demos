//
//  CustomNavigationBar.swift
//  RTRootNavigationController-Swift
//
//  Created by wuweixin on 2019/7/28.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit

class CustomNavigationBar: UINavigationBar {


    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
//        super.draw(rect)
        let path = UIBezierPath(rect: rect)
        UIColor.orange.setStroke()
        UIColor.white.setFill()
        path.fill()
        path.stroke()
    }

}
