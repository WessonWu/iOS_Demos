//
//  MTDNavigationItemView.swift
//  MTDNavigationViewDemo
//
//  Created by wuweixin on 2019/8/3.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit

open class MTDNavigationItemView: UIControl {
    open var adjustsViewWhenDisabledOrHightlight: Bool = true
    
    open override var isHighlighted: Bool {
        get {
            return super.isHighlighted
        }
        set {
            super.isHighlighted = newValue
            adjustsViewIfNeeded()
        }
    }
    
    open override var isEnabled: Bool {
        get {
            return super.isEnabled
        }
        set {
            super.isEnabled = newValue
            adjustsViewIfNeeded()
        }
    }
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commmonInitilization()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commmonInitilization()
    }
    
    func commmonInitilization() {
        
    }
    
    
    func adjustsViewIfNeeded() {
        guard self.adjustsViewWhenDisabledOrHightlight else {
            self.alpha = 1
            return
        }
        if self.isEnabled {
            self.alpha = self.isHighlighted ? 0.6 : 1
        } else {
            self.alpha = 0.4
        }
    }
}


open class MTDNavigationImageItemView: MTDNavigationItemView {
    open private(set) lazy var imageView: UIImageView = {
       let imageView = UIImageView()
        imageView.tintColor = UIColor.black
        imageView.contentMode = .center
        return imageView
    }()
    
    public convenience init(image: UIImage?, target: Any?, action: Selector?) {
        self.init()
        if let image = image {
            imageView.image = image.renderingMode == .automatic ? image.withRenderingMode(.alwaysTemplate) : image
        }
        if let target = target, let action = action {
            addTarget(target, action: action, for: .touchUpInside)
        }
    }

    override func commmonInitilization() {
        self.addSubview(imageView)
    }
    
    open override var intrinsicContentSize: CGSize {
        return CGSize(width: 32, height: 44)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.frame = imageRect(for: self.bounds)
    }
    
    open func imageRect(for bounds: CGRect) -> CGRect {
        return bounds
    }
}

open class MTDNavigationTitleItemView: MTDNavigationItemView {
    open private(set) lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.black
        label.textAlignment = .center
        return label
    }()
    
    open override var intrinsicContentSize: CGSize {
        let size = titleLabel.sizeThatFits(CGSize(width: 44 * 2, height: 44))
        return CGSize(width: size.width + 12, height: 44)
    }
    
    public convenience init(title: String?, target: Any?, action: Selector?) {
        self.init()
        titleLabel.text = title
        if let target = target, let action = action {
            addTarget(target, action: action, for: .touchUpInside)
        }
    }
    
    override func commmonInitilization() {
        self.addSubview(titleLabel)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.titleLabel.frame = textRect(for: self.bounds)
    }
    
    open func textRect(for bounds: CGRect) -> CGRect {
        return bounds
    }
}
