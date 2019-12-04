//
//  BorderView.swift
//  BunnyEarsStory
//
//  Created by wuweixin on 2018/6/25.
//  Copyright © 2018年 Xiamen Chunyou Interactive Technology Co., Ltd. All rights reserved.
//

import UIKit
import Foundation
// 顺时针方向
struct BorderMargin {
    var start: CGFloat = 0
    var end: CGFloat = 0
    
    static let `default` = BorderMargin()
}

enum BorderType: Int {
    case left = 0
    case top = 1
    case right = 2
    case bottom = 3
}

class BorderLayer: CALayer {
    var borders: Set<BorderType> = [] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var margins: [BorderType: BorderMargin] = [:] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set {
            super.frame = newValue
            setNeedsDisplay()
        }
    }
    
    // 自定义的borderWidth 不用原生的borderWidth，否则系统会绘制
    var border_width: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // 自定义的borderColor 不用原生的borderColor，否则系统会绘制
    var border_color: CGColor? = UIColor.clear.cgColor {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init() {
        super.init()
        setup()
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func setup() {
        self.contentsScale = UIScreen.main.scale
    }
    
    override func draw(in ctx: CGContext) {
        ctx.saveGState()
        ctx.setFillColor((backgroundColor ?? (UIView.appearance().backgroundColor?.cgColor ?? UIColor.clear.cgColor)))
        ctx.fill(self.bounds)
        drawBorders(in: ctx)
        ctx.restoreGState()
    }
    
    func drawBorders(in ctx: CGContext) {
        guard let strokeColor = border_color, border_width > 0 else {
            return
        }
        // 要绘制的像素值
        let pxWidth = border_width * contentsScale
        var pxAdjustOffset: CGFloat = 0
        // 顺时针
        // 如果是奇数像素，则需要调整
        if Int(pxWidth) % 2 == 1 {
            pxAdjustOffset = singleLineAdjustOffset
        }
        let offset = border_width / 2 + pxAdjustOffset
        borders.forEach { (border) in
            let margin = margins[border] ?? BorderMargin.default
            let marginStart = margin.start
            let marginEnd = margin.end
            switch border {
            case .left:
                var leftBottom = self.bounds.leftBottom
                var leftTop = self.bounds.leftTop
                // 计算x
                leftBottom.x += offset
                leftTop.x = leftBottom.x
                // 计算y
                leftBottom.y -= marginStart
                leftTop.y += marginEnd
                ctx.move(to: leftBottom)
                ctx.addLine(to: leftTop)
            case .top:
                var leftTop = self.bounds.leftTop
                var rightTop  = self.bounds.rightTop
                // 计算y
                leftTop.y += offset
                rightTop.y = leftTop.y
                // 计算x
                leftTop.x += marginStart
                rightTop.x -= marginEnd
                ctx.move(to: leftTop)
                ctx.addLine(to: rightTop)
            case .right:
                var rightTop = self.bounds.rightTop
                var rightBottom = self.bounds.rightBottom
                // 计算x
                rightTop.x -= offset
                rightBottom.x = rightTop.x
                // 计算y
                rightTop.y += marginStart
                rightBottom.y -= marginEnd
                ctx.move(to: rightTop)
                ctx.addLine(to: rightBottom)
            case .bottom:
                var rightBottom = self.bounds.rightBottom
                var leftBottom = self.bounds.leftBottom
                // 计算y
                rightBottom.y -= offset
                leftBottom.y = rightBottom.y
                // 计算x
                rightBottom.x -= marginStart
                leftBottom.x += marginEnd
                ctx.move(to: rightBottom)
                ctx.addLine(to: leftBottom)
            }
        }
        ctx.setLineWidth(border_width)
        ctx.setStrokeColor(strokeColor)
        ctx.strokePath()
    }
    
    var singleLineWidth: CGFloat {
        return 1 / scale
    }
    
    var singleLineAdjustOffset: CGFloat {
        return 1 / (scale * 2)
    }
    
    var scale: CGFloat {
        return contentsScale
    }
}

protocol BorderViewType: AnyObject {
    var borderLayer: BorderLayer { get }
    var margins: [BorderType: BorderMargin] { set get }
    var borders: Set<BorderType> { set get }
}

extension BorderViewType where Self: UIView {
    var borderLayer: BorderLayer {
        return layer as! BorderLayer
    }
    
    var margins: [BorderType: BorderMargin] {
        get {
            return borderLayer.margins
        }
        set {
            borderLayer.margins = newValue
        }
    }
    
    var borders: Set<BorderType> {
        get {
            return borderLayer.borders
        }
        set {
            borderLayer.borders = newValue
        }
    }
}

class BorderView: UIView, BorderViewType {
    override class var layerClass: Swift.AnyClass {
        return BorderLayer.self
    }
    
    var borderWidth: CGFloat {
        get {
            return borderLayer.border_width
        }
        set {
            borderLayer.border_width = newValue
        }
    }
    
    var borderColor: UIColor? {
        get {
            guard let cgColor = borderLayer.border_color else {
                return nil
            }
            return UIColor.init(cgColor: cgColor)
        }
        set {
            borderLayer.border_color = newValue?.cgColor
        }
    }
    
    override func action(for layer: CALayer, forKey event: String) -> CAAction? {
        if layer.isKind(of: BorderLayer.self) {
            return nil
        }
        return super.action(for: layer, forKey: event)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentScaleFactor = UIScreen.main.scale
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}



extension CGRect {
    var leftTop: CGPoint {
        return CGPoint(x: minX, y: minY)
    }
    
    var rightTop: CGPoint {
        return CGPoint(x: maxX, y: minY)
    }
    
    var leftBottom: CGPoint {
        return CGPoint(x: minX, y: maxY)
    }
    
    var rightBottom: CGPoint {
        return CGPoint(x: maxX, y: maxY)
    }
}
