//
//  CycleScrollFlowLayout.swift
//  CycleScrollView
//
//  Created by wuweixin on 2019/6/10.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit

class CycleScrollFlowLayout: UICollectionViewFlowLayout {
    
    var minimumScale: CGFloat = 0.8
    var maximumScale: CGFloat = 1
    var contentInset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
    var visibleSpacing: CGFloat = 12
    
    override func prepare() {
        super.prepare()
        
        guard let cv = collectionView else {
            return
        }
        
        let contentInset = self.contentInset
        let visibleSpacing = self.visibleSpacing
        let deltaScale = self.maximumScale - self.minimumScale
        cv.contentInset = contentInset
        self.scrollDirection = .horizontal
        self.itemSize = cv.frame.inset(by: contentInset).size
        let virtualSpacing = self.itemSize.width * deltaScale * 0.5 - visibleSpacing
        self.minimumInteritemSpacing = 0
        self.minimumLineSpacing = -virtualSpacing
        self.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: minimumLineSpacing)
    }
    
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
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
            }
        }
        
        return layoutAttributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        return self.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: .zero)
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
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
