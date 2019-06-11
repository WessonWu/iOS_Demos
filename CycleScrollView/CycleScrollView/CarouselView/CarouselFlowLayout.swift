//
//  CarouselFlowLayout.swift
//  CycleScrollView
//
//  Created by wuweixin on 2019/6/11.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit

/// 不要试图去修改原来UICollectionViewFlowLayout的属性，因为会失效
public class CarouselFlowLayout: UICollectionViewFlowLayout {
    public var minimumScale: CGFloat = 0.85
    public var maximumScale: CGFloat = 1
    public var padding: UIEdgeInsets = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
    public var spacing: CGFloat = 12
    
    public override func prepare() {
        super.prepare()
        
        guard let cv = collectionView else {
            return
        }
        
        let padding = self.padding
        let spacing = self.spacing
        let deltaScale = self.maximumScale - self.minimumScale
        cv.contentInset = padding
        self.scrollDirection = .horizontal
        self.itemSize = cv.frame.inset(by: padding).size
        let virtualSpacing = self.itemSize.width * deltaScale * 0.5 - spacing
        self.minimumInteritemSpacing = 0
        self.minimumLineSpacing = -virtualSpacing
        self.sectionInset = .zero
    }
    
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let layoutAttributes = super.layoutAttributesForElements(in: rect) else {
            return nil
        }
        
        if let cv = collectionView {
            let visibleRect = CGRect(origin: cv.contentOffset, size: cv.frame.size).inset(by: cv.contentInset)
            let midX = visibleRect.midX
            let minimumScale = self.minimumScale
            let maximumScale = self.maximumScale
            let deltaScale = maximumScale - minimumScale
            layoutAttributes.forEach { (attrs) in
                let distanceX = abs(attrs.center.x - midX - self.minimumInteritemSpacing)
                let scale = min(max(minimumScale, maximumScale - distanceX / visibleRect.width * deltaScale), maximumScale)
                attrs.transform3D = CATransform3DMakeScale(scale, scale, 1)
                attrs.zIndex = Int((scale * 10).rounded(.down))
            }
        }
        
        return layoutAttributes
    }
    
    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    public override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        return self.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: .zero)
    }
    
    public override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let cv = collectionView else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        }
        
        let contentInset = cv.contentInset
        let contentOffset = cv.contentOffset
        let totalWidth = itemSize.width + minimumLineSpacing
        let numberOfItems: Int = (0 ..< cv.numberOfSections).reduce(0) { $0 + cv.numberOfItems(inSection: $1) }
        let index = max(0, min((contentOffset.x + contentInset.left) / totalWidth, CGFloat(numberOfItems - 1)))
        
        let rule: FloatingPointRoundingRule
        if velocity.x > 0 {
            rule = .up
        } else if velocity.x < 0 {
            rule = .down
        } else {
            rule = .toNearestOrAwayFromZero
        }
        return CGPoint(x: index.rounded(rule) * totalWidth - contentInset.left, y: contentOffset.y)
    }
}

