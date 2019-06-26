//
//  CircleSlider.swift
//  CircleSlider
//
//  Created by wuweixin on 2019/6/25.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit

public class CircleSlider: UIControl {
    public override class var layerClass: Swift.AnyClass { return CircleSliderLayer.self }
    
    public var sliderLayer: CircleSliderLayer { return layer as! CircleSliderLayer }
    
    public private(set) lazy var thumbView: UIView = UIView()
    
    public var thumbSize: CGSize {
        return CGSize(width: 40, height: 40)
    }
    
    /// MARK - Basic Properties
    @objc dynamic public var trackColor: UIColor? {
        get {
            if let cgColor = sliderLayer.trackColor {
                return UIColor(cgColor: cgColor)
            }
            return nil
        }
        set {
            sliderLayer.trackColor = newValue?.cgColor
        }
    }
    
    @objc dynamic public var trackingColor: UIColor? {
        get {
            if let cgColor = sliderLayer.trackingColor {
                return UIColor(cgColor: cgColor)
            }
            return nil
        }
        set {
            sliderLayer.trackingColor = newValue?.cgColor
        }
    }
    
    
    @objc dynamic public var trackRadius: CGFloat {
        get {
            return sliderLayer.trackRadius
        }
        set {
            return sliderLayer.trackRadius = newValue
        }
    }
    
    @objc dynamic public var trackLineWidth: CGFloat {
        get {
            return sliderLayer.trackLineWidth
        }
        set {
            sliderLayer.trackLineWidth = newValue
        }
    }
    
    public var minimumValue: Float = 0 {
        didSet {
            if minimumValue >= maximumValue {
                fatalError("The minimumValue(\(minimumValue)) should less than maximumValue(\(maximumValue)).")
            }
        }
    }
    public var maximumValue: Float = 1 {
        didSet {
            if maximumValue <= minimumValue {
                fatalError("The maximumValue(\(maximumValue)) should greater than minimumValue(\(minimumValue)).")
            }
        }
    }
    
    
    public var currentValue: Float {
        get {
            let progress = sliderLayer.progress
            return minimumValue + progress * (maximumValue - minimumValue)
        }
        set {
            let value = min(max(minimumValue, newValue), maximumValue)
            sliderLayer.progress = value / (maximumValue - minimumValue)
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        let width = trackRadius * 2 + trackLineWidth
        return CGSize(width: width, height: width)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    public func setup() {
        // 否则strokePath边缘会模糊
        self.contentScaleFactor = UIScreen.main.scale
        self.addSubview(thumbView)
    }
    
    public override func draw(_ layer: CALayer, in ctx: CGContext) {
        if let pLayer = layer as? CircleSliderLayer {
            thumbView.frame = thumbRect(forBounds: self.bounds, value: pLayer.progress)
        }
        super.draw(layer, in: ctx)
    }
    
    public func thumbRect(forBounds bounds: CGRect, value: Float) -> CGRect {
        let alpha = -Float.pi / 2 +  value * 2 * Float.pi
        let radius = Float(trackRadius)
        let offsetX = radius * cos(alpha)
        let offsetY = radius * sin(alpha)
        let midX = bounds.midX
        let midY = bounds.midY
        let thumbSize = self.thumbSize
        return CGRect(x: midX + CGFloat(offsetX.rounded()) - thumbSize.width / 2,
                      y: midY + CGFloat(offsetY.rounded()) - thumbSize.height / 2,
                      width: thumbSize.width,
                      height: thumbSize.height)
    }
    
    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return thumbView.frame.contains(point)
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.point(inside: point, with: event) {
            return self
        }
        return nil
    }
    
    public override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        return true
    }
    
    public override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        let origin = CGPoint(x: bounds.midX, y: bounds.midY)
        let alpha = CircleSlider.alpha(from: origin, to: location)
        let expected = Float(alpha / (2 * CGFloat.pi))
        if sliderLayer.progress != expected {
            sliderLayer.progress = expected
            sendActions(for: .valueChanged)
        }
        return true
    }
    
    // 以origin作为原点，画->为x轴，画↑为y轴(alpha是与y轴正半轴的夹角)
    public class func alpha(from origin: CGPoint, to location: CGPoint) -> CGFloat {
        let deltaX = location.x - origin.x
        let deltaY = location.y - origin.y
        
        if deltaX > 0 && deltaY < 0 {
            // 第一象限(右上角)
            return atan(deltaX / -deltaY)
        }
        if deltaX > 0 && deltaY > 0 {
            // 第二象限(右下角)
            return CGFloat.pi - atan(deltaX / deltaY)
        }
        if deltaX < 0 && deltaY > 0 {
            // 第三象限(左下角)
            return CGFloat.pi + atan(-deltaX / deltaY)
        }
        if deltaX < 0 && deltaY < 0 {
            // 第四象限(左上角)
            return 2 * CGFloat.pi - atan(deltaX / deltaY)
        }
        
        // 在x或y轴上
        if deltaY == 0 {
            // 在x轴上
            if deltaX > 0 {
                // 在原点右边
                return 0.5 * CGFloat.pi
            }
            if deltaX < 0 {
                // 在原点左边
                return 1.5 * CGFloat.pi
            }
        } else {
            // 在y轴上
            if deltaY < 0 {
                // 在原点上方
                return 0
            }
            if deltaY > 0 {
                // 在原点下方
                return CGFloat.pi
            }
        }
        
        // 在原点
        return 0
    }
}

