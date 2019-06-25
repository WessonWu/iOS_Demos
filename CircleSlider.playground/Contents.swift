import UIKit
import PlaygroundSupport

public class CircleSliderLayer: CALayer {
    @NSManaged public var trackColor: CGColor?
    @NSManaged public var trackingColor: CGColor?
    
    @NSManaged public var trackRadius: CGFloat
    @NSManaged public var trackLineWidth: CGFloat
    
    @NSManaged public var progress: CGFloat
    
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
    }
    
    public func drawTrackPath(in ctx: CGContext) {
        let path = UIBezierPath(arcCenter: CGPoint(x: bounds.midX,
                                                   y: bounds.midY),
                                radius: trackRadius,
                                startAngle: 0,
                                endAngle: CGFloat.pi,
                                clockwise: true)
        ctx.addPath(path.cgPath)
        ctx.setLineWidth(self.trackLineWidth)
        ctx.setStrokeColor(self.trackColor ?? UIColor.red.cgColor)
        ctx.strokePath()
    }
    
    public func drawTrackingPath(in ctx: CGContext) {
        
    }
}

public class CircleSlider: UIControl {
    public override class var layerClass: Swift.AnyClass { return CircleSliderLayer.self }
    
    public var sliderLayer: CircleSliderLayer { return layer as! CircleSliderLayer }
    
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
    
    @objc dynamic public var progress: CGFloat {
        get {
            return sliderLayer.progress
        }
        set {
            sliderLayer.progress = newValue
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        let width = trackRadius * 2 + 20
        return CGSize(width: width, height: width)
    }
}


class TestViewController: UIViewController {
    lazy var slider = CircleSlider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        slider.trackRadius = 64
        slider.trackLineWidth = 20
        slider.progress = 10
        slider.backgroundColor = UIColor.cyan
        self.view.addSubview(slider)
        
        slider.translatesAutoresizingMaskIntoConstraints = false
        let centerX = slider.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        let centerY = slider.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        NSLayoutConstraint.activate([centerX, centerY])
        print(#function)
    }
}



PlaygroundPage.current.liveView = TestViewController()
