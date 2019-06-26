//
//  ParentLocker.swift
//  CircleSlider
//
//  Created by wuweixin on 2019/6/26.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit

final class ParentLocker: CircleSlider {
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
        sliderLayer.progress = expected
        sendActions(for: .valueChanged)
        return true
    }
}
