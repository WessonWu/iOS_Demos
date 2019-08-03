//
//  MTDNavigationItemView.swift
//  MTDNavigationViewDemo
//
//  Created by wuweixin on 2019/8/3.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit

open class MTDNavigationItemView: UIControl {
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
        imageView.contentMode = .center
        return imageView
    }()
    
    public convenience init(image: UIImage?, target: Any?, action: Selector?) {
        self.init()
        imageView.image = image
        if let target = target, let action = action {
            addTarget(target, action: action, for: .touchUpInside)
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
    
    override func commmonInitilization() {
        self.addSubview(imageView)
    }
    
    open override var intrinsicContentSize: CGSize {
        return CGSize(width: 44, height: 44)
    }
    
    open override func layoutSubviews() {
        self.imageView.frame = imageRect(for: self.bounds)
    }
    
    open func imageRect(for bounds: CGRect) -> CGRect {
        return bounds
    }
}
