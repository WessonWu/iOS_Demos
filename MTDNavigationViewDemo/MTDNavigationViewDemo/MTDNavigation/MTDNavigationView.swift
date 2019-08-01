//
//  MTDNavigationView.swift
//  MTDNavigationViewDemo
//
//  Created by wuweixin on 2019/8/1.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit

open class MTDNavigationView: UIView {
    open private(set) lazy var backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "nav_bar_back_ic"), for: .normal)
        button.tintColor = UIColor.white
        return button
    }()
    
    open private(set) lazy var titleLabel: UILabel = {
       let label = UILabel()
        let name = "PingFangSC-Medium"
        let fontDescriptor = UIFontDescriptor(name: name, size: 17)
        label.font = UIFont(descriptor: fontDescriptor, size: 17)
        label.textColor = UIColor.white
        label.textAlignment = .center
        return label
    }()
    
    open var leftNavigationItemViews: [UIView] = [] {
        didSet {
            if oldValue != self.leftNavigationItemViews {
                self.leftNavigationItemViews.forEach { $0.removeFromSuperview() }
                self.leftNavigationItemViews.forEach { self.addSubview($0) }
                self.setNeedsLayout()
            }
        }
    }
    
    open var rightNavigationItemViews: [UIView] = [] {
        didSet {
            if oldValue != self.rightNavigationItemViews {
                self.rightNavigationItemViews.forEach { $0.removeFromSuperview() }
                self.rightNavigationItemViews.forEach { self.addSubview($0) }
                self.setNeedsLayout()
            }
        }
    }
    
    open var contentEdgeInsets: UIEdgeInsets = .zero {
        didSet {
            if oldValue != self.contentEdgeInsets {
                self.setNeedsLayout()
            }
        }
    }
    
    open var contentHeight: CGFloat = 44 {
        didSet {
            if oldValue != self.contentHeight {
                self.setNeedsLayout()
            }
        }
    }
    
    open var backButtonSize: CGSize = CGSize(width: 44, height: 44) {
        didSet {
            if oldValue != self.backButtonSize {
                self.setNeedsLayout()
            }
        }
    }
    
    open var backPositionOffset: UIOffset = .zero {
        didSet {
            if oldValue != self.backPositionOffset {
                self.setNeedsLayout()
            }
        }
    }
    
    open override var intrinsicContentSize: CGSize {
        let width = UIScreen.main.bounds.width
        if #available(iOS 11.0, *) {
            return CGSize(width: width, height: max(20, self.safeAreaInsets.top) + contentHeight)
        }
        return CGSize(width: width, height: 20 + contentHeight)
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
        self.addSubview(backButton)
        self.addSubview(titleLabel)
    }
    
    
    open override func layoutSubviews() {
        var originX: CGFloat = contentEdgeInsets.left
        var originY: CGFloat = contentEdgeInsets.top
        var maxX: CGFloat = self.bounds.width - contentEdgeInsets.right
        var maxY: CGFloat = self.bounds.height - contentEdgeInsets.bottom
        if #available(iOS 11.0, *) {
            originX += self.safeAreaInsets.left
            originY += max(20, self.safeAreaInsets.top)
            maxX -= self.safeAreaInsets.right
            maxY -= self.safeAreaInsets.bottom
        } else {
            originY += 20
        }
        let contentFrame = CGRect(x: originX,
                                  y: originY,
                                  width: maxX - originX,
                                  height: maxY - originY)
        
        var backButtonOrigin = CGPoint.zero
        backButton.frame = CGRect(origin: backButtonOrigin, size: backButtonSize)
    }
}
