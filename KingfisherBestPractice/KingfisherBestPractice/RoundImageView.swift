//
//  高性能圆角ImageView
//  KingfisherBestPractice
//
//  Created by wuweixin on 2019/11/22.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit

fileprivate final class RoundingCornersCropingView: UIView {
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
    
    var isCropingEnabled: Bool {
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
        let isCropingEnabled = self.isCropingEnabled
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
    private lazy var cropingView = RoundingCornersCropingView()
    
    open var cornerRadii: CGSize {
        get {
            return cropingView.cornerRadii
        }
        set {
            cropingView.cornerRadii = newValue
        }
    }
    
    open var roundingCorners: UIRectCorner {
        get {
            return cropingView.roundingCorners
        }
        set {
            cropingView.roundingCorners = newValue
        }
    }
    
    open var roundingCornersColor: UIColor {
        get {
            return cropingView.roundingCornersColor
        }
        set {
            cropingView.roundingCornersColor = newValue
        }
    }
    
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        if newSuperview != nil {
            if cropingView.superview == nil {
                self.addSubview(cropingView)
            }
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        cropingView.frame = self.bounds
    }
}
