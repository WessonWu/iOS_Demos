import UIKit

@IBDesignable
open class FlexibleSwitch: UIControl {
    
    @IBInspectable
    open var isOn: Bool = false {
        didSet {
            self.hasDelayValueChanges = false
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable
    open var onImage: UIImage? {
        get {
            return onView.image
        }
        set {
            onView.image = newValue
        }
    }
    
    @IBInspectable
    open var onTintColor: UIColor? {
        get {
            return onView.tintColor
        }
        set {
            onView.tintColor = newValue
        }
    }
    
    @IBInspectable
    open var offImage: UIImage? {
        get {
            return offView.image
        }
        set {
            offView.image = newValue
        }
    }
    
    @IBInspectable
    open var offTintColor: UIColor? {
        get {
            return offView.tintColor
        }
        set {
            offView.tintColor = newValue
        }
    }
    
    @IBInspectable
    open var thumbImage: UIImage? {
        get {
            return thumbView.image
        }
        set {
            thumbView.image = newValue
        }
    }
    
    @IBInspectable
    open var thumbTintColor: UIColor? {
        get {
            return thumbView.tintColor
        }
        set {
            thumbView.tintColor = newValue
        }
    }
    
    
    lazy var onView: UIImageView = UIImageView(image: nil)
    lazy var offView: UIImageView = UIImageView(image: nil)
    lazy var thumbView: UIImageView = UIImageView(image: UIImage(named: "flexible_switch_thumb"))
    
    lazy var onTintLayer: CAShapeLayer = CAShapeLayer()
    lazy var offTintLayer: CAShapeLayer = CAShapeLayer()
    
    var locationOfBeginTouch: CGPoint = .zero
    var hasDelayValueChanges: Bool = false
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInitilization()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInitilization()
    }
    
    private func commonInitilization() {
        let onTintColor = UIColor(red: 0xff / 255.0,
                                  green: 0xbc / 255.0,
                                  blue: 0x1a / 255.0,
                                  alpha: 1)
        let offTintColor = UIColor(red: 0xe5 / 255.0,
                                   green: 0xe5 / 255.0,
                                   blue: 0xe5 / 255.0,
                                   alpha: 1)
        self.onTintColor = onTintColor
        self.offTintColor = offTintColor
        
        thumbView.backgroundColor = nil
        onView.backgroundColor = nil
        offView.backgroundColor = nil
        let offMask = UIView()
        offMask.backgroundColor = UIColor.black
        let onMask = UIView()
        onMask.backgroundColor = UIColor.black
        offView.mask = offMask
        onView.mask = onMask
        self.addSubview(offView)
        self.addSubview(onView)
        self.addSubview(thumbView)
    }
    
    open override func layoutSubviews() {
        onView.frame = onRect(inBounds: self.bounds)
        offView.frame = offRect(inBounds: self.bounds)
        onView.mask?.frame = onMaskRect(inBounds: onView.bounds, isOn: isOn)
        offView.mask?.frame = offMaskRect(inBounds: offView.bounds, isOn: isOn)
        thumbView.frame = thumbRect(inBounds: self.bounds, isOn: isOn)
    }
    
    
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if onImage == nil || (onImage!.isFlexibleSwitchTintImage && onImage!.size != rect.size) {
            drawTintImage(on: self.onView, with: onTintColor, size: rect.size)
        }
        
        if offImage == nil || (offImage!.isFlexibleSwitchTintImage && offImage!.size != rect.size) {
            drawTintImage(on: self.offView, with: offTintColor, size: rect.size)
        }
    }
    
    private func drawTintImage(on view: UIImageView, with tintColor: UIColor?, size: CGSize) {
        if let tintColor = tintColor {
            view.image = FlexibleSwitch.tintImage(from: tintColor, size: size)
        } else {
            view.image = nil
        }
    }
    
    open func setOn(_ on: Bool, animated: Bool) {
        self.isOn = on
        self.setNeedsLayout()
        UIView.animate(withDuration: animated ? 0.2 : 0) {
            self.layoutIfNeeded()
        }
    }
    
    open override var intrinsicContentSize: CGSize {
        return CGSize(width: 32, height: 16)
    }
    
    open func thumbRect(inBounds bounds: CGRect, isOn: Bool) -> CGRect {
        var rect: CGRect = CGRect(x: 0, y: 0, width: 28, height: 28)
        let midWidth = (rect.width / 2).rounded()
        if isOn {
            rect.origin.x = bounds.width - midWidth
        } else {
            rect.origin.x = -midWidth
        }
        rect.origin.y = (bounds.height - rect.height) / 2
        return rect
    }
    
    open func onRect(inBounds bounds: CGRect) -> CGRect {
        return bounds
    }
    
    open func offRect(inBounds bounds: CGRect) -> CGRect {
        return bounds
    }
    
    open func onMaskRect(inBounds bounds: CGRect, isOn: Bool) -> CGRect {
        return isOn ? bounds : CGRect(x: 0, y: 0, width: 0, height: bounds.height)
    }
    
    open func offMaskRect(inBounds bounds: CGRect, isOn: Bool) -> CGRect {
        return isOn ? CGRect(x: bounds.width, y: 0, width: 0, height: bounds.height) : bounds
    }
    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let touchAreaRect = bounds.union(thumbView.frame)
        return touchAreaRect.contains(point)
    }
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.point(inside: point, with: event) {
            return self
        }
        return nil
    }
    
    open override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        self.locationOfBeginTouch = touch.location(in: self)
        self.hasDelayValueChanges = true
        return true
    }
    
    open override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        let delta = location.x - locationOfBeginTouch.x
        if abs(delta) > 20 {
            self.setOn(delta > 0, animated: true)
            sendActions(for: .valueChanged)
        }
        return true
    }
    
    open override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        if hasDelayValueChanges {
            self.setOn(!isOn, animated: true)
            sendActions(for: .valueChanged)
        }
    }
    
    
    class func tintImage(from color: UIColor, size: CGSize = CGSize(width: 10, height: 10)) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        defer {
            UIGraphicsEndImageContext()
        }
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return nil
        }
        UIBezierPath(roundedRect: CGRect(origin: .zero, size: size),
                     cornerRadius: size.height / 2).addClip()
        ctx.setFillColor(color.cgColor)
        ctx.fill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        image?.isFlexibleSwitchTintImage = true
        return image
    }
}

fileprivate var FlexibleSwitch_isTintImageKey: UInt8 = 0

extension UIImage {
    var isFlexibleSwitchTintImage: Bool {
        get {
            return objc_getAssociatedObject(self, &FlexibleSwitch_isTintImageKey) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &FlexibleSwitch_isTintImageKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
}

