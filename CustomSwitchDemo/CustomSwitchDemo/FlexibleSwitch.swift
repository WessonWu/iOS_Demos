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
    
    
    lazy var onView: UIImageView = UIImageView(image: nil)
    lazy var offView: UIImageView = UIImageView(image: nil)
    lazy var thumbView: UIImageView = UIImageView(image: nil)
    
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
        let offMask = UIView()
        offMask.backgroundColor = UIColor.black
        let onMask = UIView()
        onMask.backgroundColor = UIColor.black
        offView.mask = offMask
        onView.mask = onMask
        
        thumbView.backgroundColor = UIColor.orange
        onView.backgroundColor = UIColor.cyan
        offView.backgroundColor = UIColor.lightGray
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
    
    open func setOn(_ on: Bool, animated: Bool) {
        self.isOn = on
        self.setNeedsLayout()
        UIView.animate(withDuration: animated ? 0.1 : 0) {
            self.layoutIfNeeded()
        }
    }
    
    open override var intrinsicContentSize: CGSize {
        return CGSize(width: 44, height: 16)
    }
    
    open func thumbRect(inBounds bounds: CGRect, isOn: Bool) -> CGRect {
        var rect: CGRect = CGRect(x: 0, y: 0, width: 24, height: 24)
        if isOn {
            rect.origin.x = bounds.width - rect.width
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
        let touchAreaRect = self.bounds.insetBy(dx: 0, dy: -8)
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
}

extension UIImage {
    class func from(color: UIColor, size: CGSize = CGSize(width: 10, height: 10)) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setFillColor(color.cgColor)
        ctx?.fill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

