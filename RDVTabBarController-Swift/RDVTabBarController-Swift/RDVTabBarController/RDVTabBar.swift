//
//  RDVTabBar.swift
//  RDVTabBarController-Swift
//
//  Created by wuweixin on 2019/7/17.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit


public protocol RDVTabBarDelegate: AnyObject {
    func tabBar(_ tabBar: RDVTabBar, shouldSelectItemAt index: Int) -> Bool
    func tabBar(_ tabBar: RDVTabBar, didSelectItemAt index: Int) -> Void
}

extension RDVTabBarDelegate {
    func tabBar(_ tabBar: RDVTabBar, shouldSelectItemAt index: Int) -> Bool {
        return true
    }
    func tabBar(_ tabBar: RDVTabBar, didSelectItemAt index: Int) {}
}

public class RDVTabBar: UIView {

    /// The tab bar’s delegate object.
    public weak var delegate: RDVTabBarDelegate?
    /// The items displayed on the tab bar.
    public var items: [RDVTabBarItem] = [] {
        didSet {
            let action = #selector(tabBarItemWasSelected(_:))
            oldValue.forEach { (item) in
                item.removeTarget(self, action: action, for: .touchUpInside)
                item.removeFromSuperview()
            }
            
            items.forEach { (item) in
                item.addTarget(self, action: action, for: .touchUpInside)
                self.addSubview(item)
            }
        }
    }
    /// The currently selected item on the tab bar.
    public var selectedItem: RDVTabBarItem? {
        return tabBarItem(at: selectedIndex)
    }
    
    /// backgroundView stays behind tabBar's items. If you want to add additional views,
    /// add them as subviews of backgroundView.
    public private(set) lazy var backgroundView = UIView(frame: self.bounds)
    /// contentEdgeInsets can be used to center the items in the middle of the tabBar.
    public var contentEdgeInsets: UIEdgeInsets = .zero
    /// Sets the height of tab bar.
    public var height: CGFloat {
        get {
            return self.frame.height
        }
        set {
            self.frame.size.height = newValue
        }
    }
    /// Enable or disable tabBar translucency. Default is NO.
    public var isTranslucent: Bool = false {
        didSet {
            let alpha: CGFloat = isTranslucent ? 0.9 : 1
            backgroundView.backgroundColor = UIColor(red: 245 / 255.0,
                                                     green: 245 / 255.0,
                                                     blue: 245 / 255.0,
                                                     alpha: alpha)
        }
    }
    
    var selectedIndex: Int = 0 {
        didSet {
            if selectedIndex != oldValue {
                let oldItem = tabBarItem(at: oldValue)
                let newItem = tabBarItem(at: selectedIndex)
                oldItem?.isSelected = false
                newItem?.isSelected = true
            }
        }
    }
    
    private var itemWidth: CGFloat = 50
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInitialization()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInitialization()
    }
    
    private func commonInitialization() {
        self.addSubview(backgroundView)
        
        // Accessibility
        self.isAccessibilityElement = false
    }
    
    public override func layoutSubviews() {
        let frameSize = self.frame.size
        let contentEdgeInsets = self.contentEdgeInsets
        let minimumContentHeight = self.minimumContentHeight
        self.backgroundView.frame = CGRect(x: 0,
                                           y: frameSize.height - minimumContentHeight,
                                           width: frameSize.width,
                                           height: frameSize.height)
        let avaibleWidth = frameSize.width - contentEdgeInsets.left - contentEdgeInsets.right
        let count: CGFloat = items.count > 0 ? CGFloat(items.count) : 1
        self.itemWidth = round(avaibleWidth / count)
        
        for (index, item) in items.enumerated() {
            let itemHeight = item.itemHeight ?? frameSize.height
            
            item.frame = CGRect(x: contentEdgeInsets.left + CGFloat(index) * itemWidth,
                                y: round(frameSize.height - itemHeight) - self.contentEdgeInsets.top,
                                width: self.itemWidth,
                                height: itemHeight - self.contentEdgeInsets.bottom)
            
            item.setNeedsDisplay()
        }
    }
    
    
    /// Returns the minimum height of tab bar's items.
    public var minimumContentHeight: CGFloat {
        var minimumTabBarContentHeight = self.frame.height
        
        for item in self.items {
            if let itemHeight = item.itemHeight, itemHeight < minimumTabBarContentHeight {
                minimumTabBarContentHeight = itemHeight
            }
        }
        
        return minimumTabBarContentHeight
    }
    
    
    // MARK: - Item selection
    
    @objc
    private func tabBarItemWasSelected(_ sender: UIControl) {
        guard let index = self.items.firstIndex(where: { sender.isEqual($0) }) else {
            return
        }
        
        let shouldSelectItem = self.delegate?.tabBar(self, shouldSelectItemAt: index) ?? true
        guard shouldSelectItem else {
            return
        }
        
        self.selectedIndex = index
        
        self.delegate?.tabBar(self, didSelectItemAt: index)
    }
    
    // MARK: - Accessibity
    public override func accessibilityElementCount() -> Int {
        return self.items.count
    }
    
    public override func accessibilityElement(at index: Int) -> Any? {
        return self.items[index]
    }
    
    public override func index(ofAccessibilityElement element: Any) -> Int {
        return self.items.firstIndex(where: { $0.isEqual(element) }) ?? 0
    }
    
    // MARK: - Others Internal
    
    func tabBarItem(at index: Int) -> RDVTabBarItem? {
        guard index >= 0 && index < items.count else {
            return nil
        }
        
        return items[index]
    }
}
