//
//  ImageCell.swift
//  KingfisherBestPractice
//
//  Created by wuweixin on 2019/11/21.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit

final class ImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // 第一个版本
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
    }
}
