//
//  CircleSliderLayer.swift
//  CircleSlider
//
//  Created by wuweixin on 2019/6/25.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit

public class CircleSliderLayer: CALayer {
    @NSManaged public var trackColor: CGColor?
    @NSManaged public var trackingColor: CGColor?
    
    @NSManaged public var trackRadius: CGFloat
    @NSManaged public var trackLineWidth: CGFloat
    
    @NSManaged public var progress: Float
    
    public override init() {
        super.init()
    }
    
    public override init(layer: Any) {
        super.init(layer: layer)
        if let sliderLayer = layer as? CircleSliderLayer {
            self.trackColor = sliderLayer.trackColor
            self.trackingColor = sliderLayer.trackingColor
            self.trackRadius = sliderLayer.trackRadius
            self.trackLineWidth = sliderLayer.trackLineWidth
            self.progress = sliderLayer.progress
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    // Should display if layer's property changed
    public override class func needsDisplay(forKey key: String) -> Bool {
        if key == #keyPath(trackRadius) || key == #keyPath(trackLineWidth) || key == #keyPath(progress) {
            return true
        }
        return super.needsDisplay(forKey: key)
    }
    
    // Can perform animation by UIView.animate(...)
    public override func action(forKey event: String) -> CAAction? {
        switch event {
        case #keyPath(progress):
            if let animation = super.action(forKey: #keyPath(backgroundColor)) as? CABasicAnimation {
                animation.keyPath = #keyPath(progress)
                if let pLayer = presentation() {
                    animation.fromValue = pLayer.progress
                }
                animation.isRemovedOnCompletion = true
                animation.fillMode = .forwards
                animation.toValue = nil
                return animation
            }
            return nil
        default:
            return super.action(forKey: event)
        }
    }
    
    public override func draw(in ctx: CGContext) {
        super.draw(in: ctx)
        
        // 1. draw track path
        drawTrackPath(in: ctx)
        // 2. draw tracking path
        drawTrackingPath(in: ctx)
    }
    
    public func drawTrackPath(in ctx: CGContext) {
        ctx.saveGState()
        defer {
            ctx.restoreGState()
        }
        let path = UIBezierPath(arcCenter: CGPoint(x: bounds.midX,
                                                   y: bounds.midY),
                                radius: trackRadius,
                                startAngle: 0,
                                endAngle: 2 * CGFloat.pi,
                                clockwise: true)
        ctx.addPath(path.cgPath)
        ctx.setLineWidth(self.trackLineWidth)
        ctx.setStrokeColor(self.trackColor ?? UIColor.lightGray.cgColor)
        ctx.strokePath()
    }
    
    public func drawTrackingPath(in ctx: CGContext) {
        ctx.saveGState()
        defer {
            ctx.restoreGState()
        }
        let halfOfPi = CGFloat.pi / 2
        
        let startAngle = -halfOfPi
        let endAngle = startAngle + CGFloat(progress) * 2 * CGFloat.pi
        let path = UIBezierPath(arcCenter: CGPoint(x: bounds.midX,
                                                   y: bounds.midY),
                                radius: trackRadius,
                                startAngle: startAngle,
                                endAngle: endAngle,
                                clockwise: true)
        ctx.addPath(path.cgPath)
        ctx.setLineWidth(self.trackLineWidth)
        ctx.setLineCap(.round)
        ctx.setStrokeColor(self.trackingColor ?? UIColor.orange.cgColor)
        ctx.strokePath()
    }
}
