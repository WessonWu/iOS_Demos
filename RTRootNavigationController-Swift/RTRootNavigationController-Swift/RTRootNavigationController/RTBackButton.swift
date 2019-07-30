//
//  RTBackButton.swift
//  RTRootNavigationController-Swift
//
//  Created by wuweixin on 2019/7/30.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit

open class RTBackButton: UIControl {
    public private(set) lazy var imageView: UIImageView = UIImageView(image: UIImage(named: "ic_system_nav_back", in: Bundle(for: RTRootNavigationController.self), compatibleWith: nil))
    
    open override var intrinsicContentSize: CGSize {
        return CGSize(width: 44, height: 44)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInitilization()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInitilization()
    }

    
    private func commonInitilization() {
        imageView.sizeToFit()
        self.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [NSLayoutConstraint(item: imageView,
                                              attribute: .left,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .left,
                                              multiplier: 1.0,
                                              constant: 0),
                           NSLayoutConstraint(item: imageView,
                                              attribute: .centerY,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .centerY,
                                              multiplier: 1.0,
                                              constant: 0)]
        self.addConstraints(constraints)
    }
}
