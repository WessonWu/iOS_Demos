//
//  ParentLocker.swift
//  CircleSlider
//
//  Created by wuweixin on 2019/6/26.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit

final class ParentLockerLayer: CircleSliderLayer {
    override func drawTrackPath(in ctx: CGContext) {
        super.drawTrackPath(in: ctx)
        
        ctx.saveGState()
        
        let color = UIColor.valueOf(rgb: 0xC3C3C3)
        // 指示方向
        let arcCenter = CGPoint(x: bounds.midX, y: bounds.midY)
        let halfOfPi = CGFloat.pi / 2
        let startAngle = -halfOfPi + alpha(forAngle: 30)
        let endAngle = -halfOfPi + alpha(forAngle: 116)
        let ovalPath = UIBezierPath(arcCenter: arcCenter,
                                    radius: trackRadius,
                                    startAngle: startAngle,
                                    endAngle: endAngle,
                                    clockwise: true)
        
        ctx.addPath(ovalPath.cgPath)
        ctx.setLineWidth(1)
        ctx.setLineDash(phase: 0, lengths: [4, 3])
        ctx.setStrokeColor(color.cgColor)
        ctx.strokePath()
        ctx.restoreGState()
        
        
        // 箭头 (paincode)
        ctx.saveGState()
        
        let arrowPath = UIBezierPath()
        arrowPath.move(to: CGPoint(x: 3.5, y: 0))
        arrowPath.addLine(to: CGPoint(x: 0, y: 6))
        let anchorPoint = CGPoint(x: 3.5, y: 4)
        arrowPath.addLine(to: anchorPoint) //以该点为锚点
        arrowPath.addLine(to: CGPoint(x: 7, y: 6))
        arrowPath.addLine(to: CGPoint(x: 3.5, y: 0))
        arrowPath.close()

        let offsetX = trackRadius * cos(endAngle)
        let offsetY = trackRadius * sin(endAngle)
        
        arrowPath.apply(CGAffineTransform(translationX: -anchorPoint.x, y: -anchorPoint.y))
        arrowPath.apply(CGAffineTransform(rotationAngle: CGFloat.pi + endAngle))
        arrowPath.apply(CGAffineTransform(translationX: arcCenter.x + offsetX, y: arcCenter.y + offsetY))
        
        ctx.addPath(arrowPath.cgPath)
        ctx.setFillColor(color.cgColor)
        ctx.fillPath(using: .evenOdd)
        
        ctx.restoreGState()
    }
    
    func alpha(forAngle angle: CGFloat) -> CGFloat {
        return angle / 180 * CGFloat.pi
    }
}


final class ParentLocker: CircleSlider {
    override class var layerClass: Swift.AnyClass { return ParentLockerLayer.self }
    
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


extension UIBezierPath {
    @discardableResult
    func applyRotation(anchorPoint: CGPoint, angle: CGFloat) -> UIBezierPath {
        // 1. 将anchorPoint变换到原点
        apply(CGAffineTransform(translationX: -anchorPoint.x, y: -anchorPoint.y))
        // 2. 执行旋转变换
        apply(CGAffineTransform(rotationAngle: angle))
        // 3. 将anchorPoint变换回原处
        apply(CGAffineTransform(translationX: anchorPoint.x, y: anchorPoint.y))
        return self
    }
    
    @discardableResult
    func applyTranslation(x: CGFloat, y: CGFloat) -> UIBezierPath {
        apply(CGAffineTransform(translationX: x, y: y))
        return self
    }
    
    @discardableResult
    func applyScale(anchorPoint: CGPoint, scaleX: CGFloat, scaleY: CGFloat) -> UIBezierPath {
        apply(CGAffineTransform(translationX: -anchorPoint.x, y: -anchorPoint.y))
        apply(CGAffineTransform(scaleX: scaleX, y: scaleY))
        apply(CGAffineTransform(translationX: anchorPoint.x, y: anchorPoint.y))
        return self
    }
}
