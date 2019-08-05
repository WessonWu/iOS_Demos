//
//  MTDNavigationContentView.swift
//  MTDNavigationViewDemo
//
//  Created by wuweixin on 2019/8/5.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit

final class NavigationContentView: NoBackgroundView {}

final class ShadowImageView: UIImageView {
    override var backgroundColor: UIColor? {
        get {
            return super.backgroundColor
        }
        set {
            // no background color
            super.backgroundColor = UIColor.clear
        }
    }
    
    override var image: UIImage? {
        get {
            return super.image
        }
        set {
            super.image = newValue
            if newValue == nil {
                super.backgroundColor = UIColor(red: 0xe5 / 255.0,
                                                green: 0xe5 / 255.0,
                                                blue: 0xe5 / 255.0,
                                                alpha: 1)
            } else {
                super.backgroundColor = UIColor.clear
            }
        }
    }
    
    override init(image: UIImage?) {
        super.init(image: image)
        commonInitilization()
    }
    
    override init(image: UIImage?, highlightedImage: UIImage?) {
        super.init(image: image, highlightedImage: highlightedImage)
        commonInitilization()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInitilization()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInitilization()
    }
    
    private func commonInitilization() {
        let image = self.image
        self.image = image
    }
    
    var minimumContentHeight: CGFloat {
        let minimumHeight = max(0.5, 1 / UIScreen.main.scale)
        return max(minimumHeight, image?.size.height ?? 0)
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: minimumContentHeight)
    }
}
