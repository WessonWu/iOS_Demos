//
//  BasicButton.swift
//  MTDNavigationViewDemo
//
//  Created by wuweixin on 2019/8/5.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit

open class BasicButton: UIButton {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInitilization()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInitilization()
    }
    
    func commonInitilization() {
        self.tintColor = MTDNavigationManager.style.tintColor
    }
}

open class ImageButton: BasicButton {
    public convenience init(image: UIImage?, target: Any? = nil, action: Selector? = nil) {
        self.init(type: .custom)
        setImage(image, for: .normal)
        if adjustsImageWhenHighlighted {
            setImage(image?.withAlpha(0.6), for: .highlighted)
        }
        if adjustsImageWhenDisabled {
            setImage(image?.withAlpha(0.4), for: .disabled)
        }
        if let target = target, let action = action {
            addTarget(target, action: action, for: .touchUpInside)
        }
    }
}

open class TitleButton: BasicButton {
    open override var tintColor: UIColor! {
        get {
            return super.tintColor
        }
        set {
            super.tintColor = newValue
            let color = newValue ?? MTDNavigationManager.style.tintColor
            setTitleColor(color, for: .normal)
            setTitleColor(color.withAlphaComponent(0.6), for: .highlighted)
            setTitleColor(color.withAlphaComponent(0.4), for: .disabled)
        }
    }
    
    public convenience init(title: String?, target: Any? = nil, action: Selector? = nil) {
        self.init(type: .custom)
        setTitle(title, for: .normal)
        if let target = target, let action = action {
            addTarget(target, action: action, for: .touchUpInside)
        }
    }
}

open class BackButton: ImageButton {    
    public class func `default`() -> BackButton {
        return BackButton(image: UIImage(named: "nav_bar_back_ic",
                                         in: Bundle(for: BackButton.self),
                                         compatibleWith: nil))
    }
    
    override func commonInitilization() {
        super.commonInitilization()
        self.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 8)
    }
    
    open override var intrinsicContentSize: CGSize {
        let contentSize = super.intrinsicContentSize
        return CGSize(width: contentSize.width, height: 44)
    }
}

extension UIImage {
    func withAlpha(_ alpha: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer {
            UIGraphicsEndImageContext()
        }
        draw(at: .zero, blendMode: .normal, alpha: alpha)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
