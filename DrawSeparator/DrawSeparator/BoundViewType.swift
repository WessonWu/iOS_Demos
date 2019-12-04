//
//  BoundViewType.swift
//  BunnyEarsStory
//
//  Created by wuweixin on 2018/6/25.
//  Copyright © 2018年 Xiamen Chunyou Interactive Technology Co., Ltd. All rights reserved.
//

import UIKit

// 顺时针方向
public struct BoundMargin {
    var start: CGFloat = 0
    var end: CGFloat = 0
    
    public static let `default` = BoundMargin()
}

public enum BoundType: Int {
    case left = 0
    case top = 1
    case right = 2
    case bottom = 3
}

public final class BoundViewConfiguration {
    weak var owner: BoundViewType?
    public private(set) var itemValues = ItemValues()
    public struct ItemValues {
        public var bounds: Set<BoundType>
        public var margins: [BoundType: BoundMargin]
        public var lineWidth: CGFloat
        public var strokeColor: UIColor?
        
        public init() {
            self.bounds = []
            self.margins = [:]
            self.lineWidth = 0
            self.strokeColor = nil
        }
        
        public func path(in rect: CGRect) -> CGPath? {
            guard strokeColor != nil && lineWidth > 0 else {
                return nil
            }
            let offset: CGFloat = lineWidth / 2
            let path = UIBezierPath()
            bounds.forEach { (bound) in
                let margin = margins[bound] ?? BoundMargin.default
                let marginStart = margin.start
                let marginEnd = margin.end
                switch bound {
                case .left:
                    var leftBottom = CGPoint(x: rect.minX, y: rect.maxY)
                    var leftTop = CGPoint(x: rect.minX, y: rect.minY)
                    // 计算x
                    leftBottom.x += offset
                    leftTop.x = leftBottom.x
                    // 计算y
                    leftBottom.y -= marginStart
                    leftTop.y += marginEnd
                    path.move(to: leftBottom)
                    path.addLine(to: leftTop)
                case .top:
                    var leftTop = CGPoint(x: rect.minX, y: rect.minY)
                    var rightTop  = CGPoint(x: rect.maxX, y: rect.minY)
                    // 计算y
                    leftTop.y += offset
                    rightTop.y = leftTop.y
                    // 计算x
                    leftTop.x += marginStart
                    rightTop.x -= marginEnd
                    path.move(to: leftTop)
                    path.addLine(to: rightTop)
                case .right:
                    var rightTop = CGPoint(x: rect.maxX, y: rect.minY)
                    var rightBottom = CGPoint(x: rect.maxX, y: rect.maxY)
                    // 计算x
                    rightTop.x -= offset
                    rightBottom.x = rightTop.x
                    // 计算y
                    rightTop.y += marginStart
                    rightBottom.y -= marginEnd
                    path.move(to: rightTop)
                    path.addLine(to: rightBottom)
                case .bottom:
                    var rightBottom = CGPoint(x: rect.maxX, y: rect.maxY)
                    var leftBottom = CGPoint(x: rect.minX, y: rect.maxY)
                    // 计算y
                    rightBottom.y -= offset
                    leftBottom.y = rightBottom.y
                    // 计算x
                    rightBottom.x -= marginStart
                    leftBottom.x += marginEnd
                    path.move(to: rightBottom)
                    path.addLine(to: leftBottom)
                }
            }
            return path.cgPath
        }
    }
    
    public init(owner: BoundViewType) {
        self.owner = owner
    }
    
    public func updateItemValues(with updateTask: (inout ItemValues) -> Void) {
        var itemValues = self.itemValues
        updateTask(&itemValues)
        self.itemValues = itemValues
        owner?.updatePath()
    }
    
    public class func updatePath(for view: BoundViewType) {
        let shapeLayer = view.shapeLayer
        let itemValues = view.configuration.itemValues
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = itemValues.strokeColor?.cgColor
        shapeLayer.lineWidth = itemValues.lineWidth
        shapeLayer.path = itemValues.path(in: view.bounds)
    }
}


public protocol BoundViewType: UIView {
    var shapeLayer: CAShapeLayer { get }
    var configuration: BoundViewConfiguration { get }
    func updatePath()
}

public extension BoundViewType {
    var shapeLayer: CAShapeLayer {
        #if DEBUG
        assert(layer.isKind(of: CAShapeLayer.self), NSStringFromClass(Self.self) + " must override layerClass property.")
        #endif
        return layer as! CAShapeLayer
    }
    
    func updatePath() {
        BoundViewConfiguration.updatePath(for: self)
    }
}


open class BoundView: UIView, BoundViewType {
    public private(set) lazy var configuration = BoundViewConfiguration(owner: self)
    
    open override class var layerClass: AnyClass {
        return CAShapeLayer.self
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInitialization()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInitialization()
    }
    
    private func commonInitialization() {
        shapeLayer.backgroundColor = nil
        shapeLayer.lineCap = .round
        shapeLayer.lineJoin = .round
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        updatePath()
    }
    
}
