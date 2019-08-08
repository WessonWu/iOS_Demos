//
//  MMTabBar.swift
//  MyMediaPlayer
//
//  Created by wuweixin on 2019/7/18.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit


public protocol MMTabBarDelegate: AnyObject {
    func tabBar(_ tabBar: MMTabBar, shouldSelectItemAt index: Int) -> Bool
    func tabBar(_ tabBar: MMTabBar, didSelectItemAt index: Int) -> Void
}

extension MMTabBarDelegate {
    func tabBar(_ tabBar: MMTabBar, shouldSelectItemAt index: Int) -> Bool {
        return true
    }
    func tabBar(_ tabBar: MMTabBar, didSelectItemAt index: Int) {}
}

public class MMTabBar: UIView {
    
    public weak var delegate: MMTabBarDelegate?

    public var items: [MMTabBarItem] = [] {
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
    
    public var selectedItem: MMTabBarItem? {
        return tabBarItem(at: self.selectedIndex)
    }
    
    public var minimumContentHeight: CGFloat = 49
    
    public var contentEdgeInsets: UIEdgeInsets = .zero
    
    public var automaticallyAdjustsContentInsets: Bool = true
    
    
    var selectedIndex: Int = 0 {
        didSet {
            if selectedIndex != oldValue {
                let tabBarItem = self.tabBarItem(at: oldValue)
                tabBarItem?.isSelected = false
            }
            let tabBarItem = self.tabBarItem(at: self.selectedIndex)
            tabBarItem?.isSelected = true
        }
    }
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInitialization()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInitialization()
    }
    
    private func commonInitialization() {
        self.backgroundColor = UIColor.white
    }
    
    public override func layoutSubviews() {
        let frameSize = self.frame.size
        var contentEdgeInsets = self.contentEdgeInsets
        if #available(iOS 11.0, *), automaticallyAdjustsContentInsets {
            let safeAreaInsets = self.safeAreaInsets
            contentEdgeInsets.top += safeAreaInsets.top
            contentEdgeInsets.left += safeAreaInsets.left
            contentEdgeInsets.bottom += safeAreaInsets.bottom
            contentEdgeInsets.right += safeAreaInsets.right
        }
        let avaibleWidth = frameSize.width - contentEdgeInsets.left - contentEdgeInsets.right
        let count: CGFloat = items.count > 0 ? CGFloat(items.count) : 1
        let itemWidth = round(avaibleWidth / count)
        let itemHeight = self.minimumContentHeight + contentEdgeInsets.top + contentEdgeInsets.bottom
        // Layout Items
        for (index, item) in items.enumerated() {
            
            item.frame = CGRect(x: contentEdgeInsets.left + CGFloat(index) * itemWidth,
                                y: round(frameSize.height - itemHeight) - contentEdgeInsets.top,
                                width: itemWidth,
                                height: itemHeight - contentEdgeInsets.bottom)
            
            item.setNeedsDisplay()
        }
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
    
    // MARK: - Others Internal
    
    func tabBarItem(at index: Int) -> MMTabBarItem? {
        guard index >= 0 && index < items.count else {
            return nil
        }
        
        return items[index]
    }
}
