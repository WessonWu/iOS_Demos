import UIKit

open class FlexibleSwitch: UIControl {
    open var isOn: Bool = false
    
    
    lazy var onView: UIImageView = UIImageView(image: nil)
    lazy var offView: UIImageView = UIImageView(image: nil)
    lazy var thumbView: UIImageView = UIImageView(image: nil)
    
    lazy var onMask: UIView = UIView()
    lazy var offMask: UIView = UIView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInitilization()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInitilization()
    }
    
    private func commonInitilization() {
        offMask.backgroundColor = UIColor.black
        onMask.backgroundColor = UIColor.black
        offView.mask = offMask
        onView.mask = onMask
        
        thumbView.backgroundColor = UIColor.orange
        onView.backgroundColor = UIColor.cyan
        offView.backgroundColor = UIColor.lightGray
        self.addSubview(offView)
        self.addSubview(onView)
    }
    
    open override func layoutSubviews() {
        onView.frame = onRect(inBounds: self.bounds)
        offView.frame = offRect(inBounds: self.bounds)
        onMask.frame = onMaskRect(inBounds: onView.bounds, isOn: isOn)
        offMask.frame = offMaskRect(inBounds: offView.bounds, isOn: isOn)
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

