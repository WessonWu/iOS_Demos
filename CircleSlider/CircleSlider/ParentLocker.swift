//
//  ParentLocker.swift
//  CircleSlider
//
//  Created by wuweixin on 2019/6/26.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit

final class ParentLocker: CircleSlider {
    
    lazy var imageView = UIImageView(image: #imageLiteral(resourceName: "ic_radish"))
    
    override var thumbSize: CGSize {
        return CGSize(width: 52, height: 52)
    }
    
    override func setup() {
        super.setup()
        
        self.backgroundColor = UIColor.white
        self.trackRadius = 63
        self.trackLineWidth = 18
        self.trackColor = UIColor.valueOf(rgb: 0xe9e9e9)
        self.trackingColor = UIColor.valueOf(rgb: 0xffc152)
        self.minimumValue = 0
        self.maximumValue = 360
        
        self.imageView.frame = thumbView.bounds
        self.imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.thumbView.addSubview(imageView)
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        let origin = CGPoint(x: bounds.midX, y: bounds.midY)
        let alpha = CircleSlider.alpha(from: origin, to: location)
        var expected = Float(alpha / (2 * CGFloat.pi))
        // 不能重复旋转
        let previous = sliderLayer.progress
        let distance = expected - previous
        if distance > 0.5 {
            expected = 0
        } else if distance < -0.5 {
            expected = 1
        }
        if sliderLayer.progress != expected {
            sliderLayer.progress = expected
            sendActions(for: .valueChanged)
        }
        return true
    }
}


extension UIColor {
    class func valueOf(argb: UInt32) -> UIColor {
        let alpha = CGFloat((argb >> 24) & 0xFF) / 255
        let red = CGFloat((argb >> 16) & 0xFF) / 255
        let green = CGFloat((argb >> 8) & 0xFF) / 255
        let blue = CGFloat(argb & 0xFF) / 255
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    class func valueOf(rgb: UInt32) -> UIColor {
        return valueOf(argb: rgb | 0xFF000000)
    }
}
