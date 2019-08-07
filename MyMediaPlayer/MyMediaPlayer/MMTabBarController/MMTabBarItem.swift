//
//  MMTabBarItem.swift
//  MyMediaPlayer
//
//  Created by wuweixin on 2019/7/18.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit

open class MMTabBarItem: UIControl {
    // MARK: - Title configuration
    
    /// The title displayed by the tab bar item.
    open var title: String?
    /// The offset for the rectangle around the tab bar item's title.
    open var titlePositionAdjustment: UIOffset = .zero
    
    /// For title's text attributes see
    /// https://developer.apple.com/library/ios/documentation/uikit/reference/NSString_UIKit_Additions/Reference/Reference.html
    
    /// The title attributes dictionary used for tab bar item's unselected state.
    open var unselectedTitleAttributes: [NSAttributedString.Key: Any]?
    /// The title attributes dictionary used for tab bar item's selected state.
    open var selectedTitleAttributes: [NSAttributedString.Key: Any]?
    
    // MARK: - Image configuration
    
    /// The offset for the rectangle around the tab bar item's image.
    open var imagePositionAdjustment: UIOffset = .zero
    
    /// The image used for tab bar item's selected state.
    open var finishedSelectedImage: UIImage?
    /// The image used for tab bar item's unselected state.
    open var finishedUnselectedImage: UIImage?
    
    // MARK: - Background configuration
    
    /// The background image used for tab bar item's selected state.
    open var backgroundSelectedImage: UIImage?
    /// The background image used for tab bar item's unselected state.
    open var backgroundUnselectedImage: UIImage?
    
    // MARK: - Badge configuration
    
    /// Text that is displayed in the upper-right corner of the item with a surrounding background.
    open var badgeValue: String? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    /// Image used for background of badge.
    open var badgeBackgroundImage: UIImage?
    /// Color used for badge's background.
    open var badgeBackgroundColor: UIColor? = UIColor.red
    /// The offset for the rectangle around the tab bar item's badge.
    open var badgePositionAdjustment: UIOffset = .zero
    /// Insets used for badge's text.
    open var badgeTextInsets: UIEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
    
    /// the text attributes for badge.
    open var badgeTextAttributes: [NSAttributedString.Key: Any]?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInitialization()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInitialization()
    }
    
    private func commonInitialization() {
        // Setup defaults
        self.backgroundColor = UIColor.clear
        
        unselectedTitleAttributes = [.font: UIFont.systemFont(ofSize: 12),
                                     .foregroundColor: UIColor.black]
        selectedTitleAttributes = unselectedTitleAttributes
        
        let badgeTextStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        badgeTextStyle.lineBreakMode = .byWordWrapping
        badgeTextStyle.alignment = .center
        badgeTextAttributes = [.font: UIFont.systemFont(ofSize: 12),
                               .foregroundColor: UIColor.white,
                               .paragraphStyle: badgeTextStyle]
        
        // Accessibility
        self.accessibilityLabel = "tabBarItem"
        self.isAccessibilityElement = true
    }
    
    
    open override func draw(_ rect: CGRect) {
        let frameSize = self.frame.size
        
        let backgroundImage: UIImage?
        let image: UIImage?
        let titleAttributes: [NSAttributedString.Key: Any]?
        
        if self.isSelected {
            backgroundImage = self.backgroundSelectedImage
            image = self.finishedSelectedImage
            if self.selectedTitleAttributes == nil {
                titleAttributes = unselectedTitleAttributes
            } else {
                titleAttributes = selectedTitleAttributes
            }
        } else {
            backgroundImage = self.backgroundUnselectedImage
            image = self.finishedUnselectedImage
            titleAttributes = self.unselectedTitleAttributes
        }
        
        let imageSize: CGSize = image?.size ?? .zero
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        context.saveGState()
        defer {
            context.restoreGState()
        }
        
        // Draw background image
        backgroundImage?.draw(in: self.bounds)
        
        // Draw image and title
        if let title = self.title, title.count > 0 {
            let titleSize = (title as NSString).boundingRect(with: CGSize(width: frameSize.width, height: 20),
                                                             options: .usesLineFragmentOrigin,
                                                             attributes: titleAttributes,
                                                             context: nil).size
            let imageStartingY = round((frameSize.height - imageSize.height - titleSize.height) / 2)
            let imageFrame = CGRect(x: round((frameSize.width - imageSize.width) / 2) + imagePositionAdjustment.horizontal,
                                    y: imageStartingY + imagePositionAdjustment.vertical,
                                    width: imageSize.width,
                                    height: imageSize.height)
            image?.draw(in: imageFrame)
            
            if let textColor = titleAttributes?[.foregroundColor] as? UIColor {
                context.setFillColor(textColor.cgColor)
            }
            
            let textFrame = CGRect(x: round((frameSize.width - titleSize.width) / 2) + titlePositionAdjustment.horizontal,
                                   y: imageStartingY + imageSize.height + titlePositionAdjustment.vertical,
                                   width: titleSize.width,
                                   height: titleSize.height)
            (title as NSString).draw(in: textFrame,
                                     withAttributes: titleAttributes)
        } else {
            image?.draw(in: CGRect(x: round((frameSize.width - imageSize.width) / 2) + imagePositionAdjustment.horizontal,
                                   y: round((frameSize.height - imageSize.height) / 2) + imagePositionAdjustment.vertical,
                                   width: imageSize.width,
                                   height: imageSize.height))
        }
        
        // Draw badges
        guard let badgeValue = self.badgeValue, badgeValue.count > 0 else {
            return
        }
        
        let badgeTextAttributes = self.badgeTextAttributes
        
        var badgeSize = (badgeValue as NSString).boundingRect(with: CGSize(width: frameSize.width, height: 20),
                                                              options: .usesLineFragmentOrigin,
                                                              attributes: badgeTextAttributes,
                                                              context: nil).size
        
        if badgeSize.width < badgeSize.height {
            badgeSize.width = badgeSize.height
        }
        
        let badgeBackgroundFrame = CGRect(x: round(frameSize.width / 2 + imageSize.width / 2 * 0.9) + badgePositionAdjustment.horizontal,
                                          y: 2 + badgePositionAdjustment.vertical,
                                          width: badgeSize.width + badgeTextInsets.left + badgeTextInsets.right,
                                          height: badgeSize.height + badgeTextInsets.top + badgeTextInsets.bottom)
        
        if let badgeBackgroundColor = self.badgeBackgroundColor {
            context.setFillColor(badgeBackgroundColor.cgColor)
            context.fillEllipse(in: badgeBackgroundFrame)
        } else if let badgeBackgroundImage = self.badgeBackgroundImage {
            badgeBackgroundImage.draw(in: badgeBackgroundFrame)
        }
        
        if let badgeTextColor = self.badgeTextAttributes?[.foregroundColor] as? UIColor {
            context.setFillColor(badgeTextColor.cgColor)
        }
        
        let badgeTextStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        badgeTextStyle.lineBreakMode = .byWordWrapping
        badgeTextStyle.alignment = .center
        
        (badgeValue as NSString).draw(in: CGRect(x: badgeBackgroundFrame.minX + badgeTextInsets.left,
                                                 y: badgeBackgroundFrame.minY + badgeTextInsets.top,
                                                 width: badgeSize.width,
                                                 height: badgeSize.height),
                                      withAttributes: badgeTextAttributes)
    }
}
