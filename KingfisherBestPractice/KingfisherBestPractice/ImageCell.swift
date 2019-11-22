//
//  ImageCell.swift
//  KingfisherBestPractice
//
//  Created by wuweixin on 2019/11/21.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit
import Kingfisher

final class ImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: RoundImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.frame = self.bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // 第一个版本
//        imageView.layer.cornerRadius = 8
//        imageView.layer.masksToBounds = true
        
        
        // 圆角采用这种方式
        imageView.roundingCornersColor = UIColor.white
        imageView.roundingCorners = .allCorners
        imageView.cornerRadii = CGSize(width: 8, height: 8)
    }
}
