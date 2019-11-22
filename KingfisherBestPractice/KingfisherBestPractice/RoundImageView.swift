//
//  高性能圆角ImageView
//  KingfisherBestPractice
//
//  Created by wuweixin on 2019/11/22.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit

fileprivate final class RoundingCornersCroppingView: UIView {
    override class var layerClass: AnyClass {
        return CAShapeLayer.self
    }
    
    var shapeLayer: CAShapeLayer {
        return layer as! CAShapeLayer
    }
    
    var roundingCorners: UIRectCorner = [] {
        didSet {
            drawPaths()
        }
    }
    var cornerRadii: CGSize = .zero {
        didSet {
            drawPaths()
        }
    }
    var roundingCornersColor: UIColor = UIColor.white {
        didSet {
            shapeLayer.fillColor = roundingCornersColor.cgColor
            setNeedsDisplay()
        }
    }
    
    var isCroppingEnabled: Bool {
        return roundingCorners != [] && cornerRadii != .zero
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInitilization()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInitilization()
    }
    
    private func commonInitilization() {
        isUserInteractionEnabled = false
        backgroundColor = UIColor.clear
        roundingCornersColor = UIColor.white
        shapeLayer.fillRule = .evenOdd
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        drawPaths()
    }
    
    private func drawPaths() {
        let isCropingEnabled = self.isCroppingEnabled
        self.isHidden = !isCropingEnabled
        guard isCropingEnabled && self.bounds != .zero else {
            shapeLayer.path = nil
            return
        }
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: roundingCorners, cornerRadii: cornerRadii)
        path.append(UIBezierPath(rect: self.bounds))
        path.close()
        shapeLayer.path = path.cgPath
    }
}

open class RoundImageView: UIImageView {
    private lazy var croppingView = RoundingCornersCroppingView()
    
    open var cornerRadii: CGSize {
        get {
            return croppingView.cornerRadii
        }
        set {
            croppingView.cornerRadii = newValue
        }
    }
    
    open var roundingCorners: UIRectCorner {
        get {
            return croppingView.roundingCorners
        }
        set {
            croppingView.roundingCorners = newValue
        }
    }
    
    open var roundingCornersColor: UIColor {
        get {
            return croppingView.roundingCornersColor
        }
        set {
            croppingView.roundingCornersColor = newValue
        }
    }
    
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        if newSuperview != nil {
            if croppingView.superview == nil {
                self.addSubview(croppingView)
            }
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        croppingView.frame = self.bounds
        if croppingView.superview == self {
            self.bringSubviewToFront(croppingView)
        }
    }
}
