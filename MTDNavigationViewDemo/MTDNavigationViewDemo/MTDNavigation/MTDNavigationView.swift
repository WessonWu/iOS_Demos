//
//  MTDNavigationView.swift
//  MTDNavigationViewDemo
//
//  Created by wuweixin on 2019/8/1.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit

public protocol MTDNavigationViewDelegate: AnyObject {
    func performBackAction(in navigationView: MTDNavigationView)
}

public extension MTDNavigationViewDelegate {
    func performBackAction(in navigationView: MTDNavigationView) {}
}

open class MTDNavigationView: UIView {
    
    open weak var delegate: MTDNavigationViewDelegate?
    
    open private(set) lazy var backButton: UIControl = MTDNavigationManager.backButton()
    open private(set) lazy var titleLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = MTDNavigationManager.style.titleColor
        label.textAlignment = .center
        return label
    }()
    
    
    open private(set) lazy var contentView: UIView = NavigationContentView()
    open private(set) lazy var shadowImageView: UIImageView = ShadowImageView()
    
    open var leftNavigationItemViews: [UIView] = [] {
        didSet {
            if oldValue != self.leftNavigationItemViews {
                self.onLeftNavigationItemsChanged(self.leftNavigationItemViews, oldItems: oldValue)
                self.setNeedsLayout()
            }
        }
    }
    
    open var rightNavigationItemViews: [UIView] = [] {
        didSet {
            if oldValue != self.rightNavigationItemViews {
                self.onRightNavigationItemsChanged(self.rightNavigationItemViews, oldItems: oldValue)
                self.setNeedsLayout()
            }
        }
    }
    
    private var leftItemsStackView: UIStackView = {
       let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 0
        return stackView
    }()
    
    private var rightItemsStackView: UIStackView = {
       let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 0
        return stackView
    }()
    
    open override var intrinsicContentSize: CGSize {
        let width = UIScreen.main.bounds.width
        if #available(iOS 11.0, *) {
            return CGSize(width: width, height: max(20, self.safeAreaInsets.top) + contentHeight)
        }
        return CGSize(width: width, height: 20 + contentHeight)
    }
    
    open var contentHeight: CGFloat {
        return MTDNavigationManager.style.contentHeight
    }
    
    /// A Boolean value indicating whether the navigation view is translucent (true) or not (false).
    open var isTranslucent: Bool = false {
        didSet {
            self.superview?.setNeedsLayout()
        }
    }
    
    open var itemSpacing: CGFloat = 0 {
        didSet {
            leftItemsStackView.spacing = itemSpacing
            rightItemsStackView.spacing = itemSpacing
        }
    }
    
    open private(set) var isNavigationViewHidden: Bool = false
    open override var isHidden: Bool {
        get {
            return super.isHidden
        }
        set {
            self.setNavigationViewHidden(newValue)
        }
    }
    
    /// 自动设置返回按钮显示/隐藏(处在MTDNavigationController时才有用)
    open var automaticallyAdjustsBackItemHidden: Bool = true
    
    var backItemHiddenObservation: NSKeyValueObservation?
    
    private weak var showBackButtonConstraint: NSLayoutConstraint?
    private weak var hideBackButtonConstraint: NSLayoutConstraint?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInitilization()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInitilization()
    }
    
    private func commonInitilization() {
        self.clipsToBounds = false
        self.backgroundColor = MTDNavigationManager.style.backgroundColor
        self.backButton.addTarget(self, action: #selector(onBackClick(_:)), for: .touchUpInside)
        self.isNavigationViewHidden = super.isHidden
        
        self.addSubview(contentView)
        self.addSubview(shadowImageView)
        contentView.addSubview(backButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(leftItemsStackView)
        contentView.addSubview(rightItemsStackView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        shadowImageView.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        leftItemsStackView.translatesAutoresizingMaskIntoConstraints = false
        rightItemsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.layoutMargins = .zero
        contentView.topAnchor.constraint(greaterThanOrEqualTo: self.topAnchor, constant: 20).setup { (constraint) in
            constraint.priority = UILayoutPriority(950)
            constraint.isActive = true
        }
        if #available(iOS 11.0, *) {
            self.directionalLayoutMargins = .zero
            contentView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor).setup { (constraint) in
                constraint.priority = UILayoutPriority(900)
                constraint.isActive = true
            }
        }
        contentView.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor).setup { (constraint) in
            constraint.priority = UILayoutPriority(999)
            constraint.isActive = true
        }
        contentView.heightAnchor.constraint(equalToConstant: contentHeight).isActive = true
        contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        backButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        backButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        leftItemsStackView.heightAnchor.constraint(equalTo: contentView.heightAnchor).isActive = true
        leftItemsStackView.widthAnchor.constraint(equalToConstant: 0).setup { (constraint) in
            constraint.priority = UILayoutPriority(200)
            constraint.isActive = true
        }
        leftItemsStackView.leadingAnchor.constraint(equalTo: backButton.trailingAnchor).setup { (constraint) in
            self.showBackButtonConstraint = constraint
        }
        leftItemsStackView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).setup { (constraint) in
            self.hideBackButtonConstraint = constraint
        }
        leftItemsStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        rightItemsStackView.heightAnchor.constraint(equalTo: contentView.heightAnchor).isActive = true
        rightItemsStackView.widthAnchor.constraint(equalToConstant: 0).setup { (constraint) in
            constraint.priority = UILayoutPriority(200)
            constraint.isActive = true
        }
        rightItemsStackView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
        rightItemsStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        shadowImageView.topAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        shadowImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        shadowImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        
        self.onBackButtonHidden(backButton.isHidden)
        self.backItemHiddenObservation = backButton.observe(\.isHidden, changeHandler: { [weak self] (button, _) in
            self?.onBackButtonHidden(button.isHidden)
        })
    }
    
    open func onBackButtonHidden(_ isHidden: Bool) {
        if isHidden {
            self.showBackButtonConstraint?.isActive = false
            self.hideBackButtonConstraint?.isActive = true
        } else {
            self.hideBackButtonConstraint?.isActive = false
            self.showBackButtonConstraint?.isActive = true
        }
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    open func onLeftNavigationItemsChanged(_ navigationItems: [UIView], oldItems: [UIView]) {
        oldItems.forEach { (item) in
            leftItemsStackView.removeArrangedSubview(item)
            item.removeFromSuperview()
        }
        
        navigationItems.forEach { (item) in
            leftItemsStackView.addArrangedSubview(item)
        }
    }
    
    open func onRightNavigationItemsChanged(_ navigationItems: [UIView], oldItems: [UIView]) {
        oldItems.forEach { (item) in
            rightItemsStackView.removeArrangedSubview(item)
            item.removeFromSuperview()
        }
        
        navigationItems.forEach { (item) in
            rightItemsStackView.addArrangedSubview(item)
        }
    }
    
    public func setNavigationViewHidden(_ hidden: Bool, animations: (() -> Void)? = nil, completion: ((Bool) -> Void)? = nil) {
        guard self.isNavigationViewHidden != hidden else {
            return
        }
        self.isNavigationViewHidden = hidden
        if let animations = animations {
            if !self.isNavigationViewHidden {
                super.isHidden = false
            }
            let duration = TimeInterval(UINavigationController.hideShowBarDuration)
            UIView.animate(withDuration: duration, animations: animations, completion: { finished in
                super.isHidden = self.isNavigationViewHidden
                completion?(finished)
            })
        } else {
            super.isHidden = hidden
            completion?(true)
        }
    }
    
    @objc
    private func onBackClick(_ sender: Any) {
        delegate?.performBackAction(in: self)
    }
    
    deinit {
        self.backItemHiddenObservation?.invalidate()
        self.backItemHiddenObservation = nil
    }
}
