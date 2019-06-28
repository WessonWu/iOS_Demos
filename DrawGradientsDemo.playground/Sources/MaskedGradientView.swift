import UIKit

/*
 Quartz2D可以用来绘制渐变图形,即图形向外或向内发散，会变得越来越模糊。
 
 渐变分为线性渐变和径向渐变，所谓线性渐变，就是图形以线的方式发散，发散后一般呈现出矩形的样子；而径向渐变，就是以半径的大小往外或往内发散，发散后呈现出圆形的样子。
 
 渐变系数：0.0~1.0
 渐变模式：可以进行与操作
 
 drawsBeforeStartLocation = (1 << 0),  //向内渐变
 drawsAfterEndLocation = (1 << 1)      //向外渐变
 */


public class MaskedGradientLayer: CALayer {
    @NSManaged public var startPoint: CGPoint
    @NSManaged public var endPoint: CGPoint
    @NSManaged public var locations: [CGFloat]?
    @NSManaged public var colors: [CGColor]
    
    @NSManaged public var maskedRadius: CGFloat
    @NSManaged public var maskedRectCorner: UIRectCorner
    
    public override init() {
        super.init()
    }
    
    public override init(layer: Any) {
        super.init(layer: layer)
        if let pLayer = layer as? MaskedGradientLayer {
            self.startPoint = pLayer.startPoint
            self.endPoint = pLayer.endPoint
            self.locations = pLayer.locations
            self.colors = pLayer.colors
            self.maskedRadius = pLayer.maskedRadius
            self.maskedRectCorner = pLayer.maskedRectCorner
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override class func needsDisplay(forKey key: String) -> Bool {
        switch key {
        case #keyPath(startPoint),
             #keyPath(endPoint),
             #keyPath(locations),
             #keyPath(colors),
             #keyPath(maskedRadius),
             #keyPath(maskedRectCorner):
            return true
        default:
            break
        }
        return super.needsDisplay(forKey: key)
    }
    
    public override func draw(in ctx: CGContext) {
        super.draw(in: ctx)
        ctx.saveGState()
        defer {
            ctx.restoreGState()
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorComponents = colors.flatMap { return $0.components ?? [] }
        let locations = self.locations
        let startPoint = self.startPoint.applying(CGAffineTransform(scaleX: bounds.width, y: bounds.height))
        let endPoint = self.endPoint.applying(CGAffineTransform(scaleX: bounds.width, y: bounds.height))
        guard let gradient = CGGradient(colorSpace: colorSpace,
                                        colorComponents: colorComponents,
                                        locations: locations,
                                        count: locations?.count ?? 0) else {
                                            return
        }
        
        let radius = self.maskedRadius
        let corners = self.maskedRectCorner
        if radius > 0 && !corners.isEmpty {
            let path = UIBezierPath(roundedRect: self.bounds,
                                    byRoundingCorners: corners,
                                    cornerRadii: CGSize(width: radius, height: radius))
            ctx.addPath(path.cgPath)
            ctx.clip(using: .evenOdd)
        }
        ctx.drawLinearGradient(gradient,
                               start: startPoint,
                               end: endPoint,
                               options: .drawsAfterEndLocation)
    }
}


public class MaskedGradientView: UIView {
    public override class var layerClass: Swift.AnyClass { return MaskedGradientLayer.self }
    public var gradientLayer: MaskedGradientLayer { return layer as! MaskedGradientLayer }
    
    public dynamic var startPoint: CGPoint {
        get {
            return gradientLayer.startPoint
        }
        set {
            gradientLayer.startPoint = newValue
        }
    }
    public dynamic var endPoint: CGPoint {
        get {
            return gradientLayer.endPoint
        }
        set {
            gradientLayer.endPoint = newValue
        }
    }
    
    public dynamic var locations: [CGFloat]? {
        get {
            return gradientLayer.locations
        }
        set {
            gradientLayer.locations = newValue
        }
    }
    
    public dynamic var colors: [CGColor] {
        get {
            return gradientLayer.colors
        }
        set {
            gradientLayer.colors = newValue
        }
    }
    
    public dynamic var maskedRadius: CGFloat {
        get {
            return gradientLayer.maskedRadius
        }
        set {
            gradientLayer.maskedRadius = newValue
        }
    }
    
    public dynamic var maskedCorners: UIRectCorner {
        get {
            return gradientLayer.maskedRectCorner
        }
        set {
            gradientLayer.maskedRectCorner = newValue
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    func setup() {
        self.backgroundColor = UIColor.clear
        self.gradientLayer.contentsScale = UIScreen.main.scale
    }
}
