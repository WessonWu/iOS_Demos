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
        return CGSize(width: 52, height: 52)
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
    
    @objc dynamic public var progress: Float {
        get {
            return sliderLayer.progress
        }
        set {
            sliderLayer.progress = newValue
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
        thumbView.backgroundColor = UIColor.green
        self.addSubview(thumbView)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        thumbView.frame = thumbRect(forBounds: self.bounds, value: progress)
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
}

