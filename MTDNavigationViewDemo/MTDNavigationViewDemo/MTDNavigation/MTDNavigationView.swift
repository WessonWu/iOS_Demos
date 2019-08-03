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
    
    open private(set) lazy var backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "nav_bar_back_ic")?.withRenderingMode(.alwaysTemplate), for: .normal)
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
    
    
    open private(set) lazy var contentView: UIView = {
       let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }()
    
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
            return CGSize(width: width, height: max(20, self.safeAreaInsets.top) + 44)
        }
        return CGSize(width: width, height: 20 + 44)
    }
    
    /// A Boolean value indicating whether the navigation view is translucent (true) or not (false).
    open var isTranslucent: Bool = false {
        didSet {
            self.superview?.setNeedsUpdateConstraints()
            self.superview?.updateConstraintsIfNeeded()
        }
    }
    
    /// 自动设置返回按钮显示/隐藏(处在MTDNavigationController时才有用)
    open var automaticallyAdjustsBackItemHidden: Bool = true

    open weak var owning: UIViewController? {
        didSet {
            self.titleObservation?.invalidate()
            self.titleObservation = nil
            self.titleLabel.text = owning?.title
            self.titleObservation = owning?.observe(\.title, options: [.new, .old], changeHandler: { [weak self] (vc, _) in
                self?.titleLabel.text = vc.title
            })
        }
    }
    
    var backItemHiddenObservation: NSKeyValueObservation?
    var titleObservation: NSKeyValueObservation?
    
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
        self.backgroundColor = UIColor.cyan
        self.backButton.addTarget(self, action: #selector(onBackClick(_:)), for: .touchUpInside)
        
        self.addSubview(contentView)
        contentView.addSubview(backButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(leftItemsStackView)
        contentView.addSubview(rightItemsStackView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        leftItemsStackView.translatesAutoresizingMaskIntoConstraints = false
        rightItemsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.layoutMargins = .zero
        let contentViewTopConstraint = contentView.topAnchor.constraint(greaterThanOrEqualTo: self.topAnchor, constant: 20)
        contentViewTopConstraint.priority = UILayoutPriority(950)
        contentViewTopConstraint.isActive = true
        if #available(iOS 11.0, *) {
            self.directionalLayoutMargins = .zero
            let safeTopConstraint = contentView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor)
            safeTopConstraint.priority = UILayoutPriority(900)
            safeTopConstraint.isActive = true
        }
        contentView.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor).isActive = true
        contentView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        backButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        backButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        backButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        leftItemsStackView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        let leftWidthConstraint = leftItemsStackView.widthAnchor.constraint(equalToConstant: 0)
        leftWidthConstraint.priority = UILayoutPriority(200)
        leftWidthConstraint.isActive = true
        
        let showBackButtonConstraint = leftItemsStackView.leadingAnchor.constraint(equalTo: backButton.trailingAnchor)
        let hideBackButtonConstraint = leftItemsStackView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor)
        self.showBackButtonConstraint = showBackButtonConstraint
        self.hideBackButtonConstraint = hideBackButtonConstraint
        
        leftItemsStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        rightItemsStackView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        let rightWidthConstraint = rightItemsStackView.widthAnchor.constraint(equalToConstant: 0)
        rightWidthConstraint.priority = UILayoutPriority(200)
        rightWidthConstraint.isActive = true
        rightItemsStackView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
        rightItemsStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        
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
    
    @objc
    private func onBackClick(_ sender: Any) {
        delegate?.performBackAction(in: self)
    }
    
    deinit {
        self.backItemHiddenObservation?.invalidate()
        self.backItemHiddenObservation = nil
    }
}
