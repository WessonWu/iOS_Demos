//
//  CycleScrollViewItemCell.swift
//  CycleScrollView
//
//  Created by wuweixin on 2019/6/10.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit

final class CycleScrollViewItemCell: UICollectionViewCell {
    static let reuseIdentifier: String = NSStringFromClass(CycleScrollViewItemCell.self)
    
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        setupAutoLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func setupAutoLayout() {
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.frame = contentView.bounds
        contentView.addSubview(imageView)
    }
}
