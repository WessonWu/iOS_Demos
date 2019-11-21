//
//  ImageFlowLayout.swift
//  KingfisherBestPractice
//
//  Created by wuweixin on 2019/11/21.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit

final class ImageFlowLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        
        guard let cv = self.collectionView else {
            return
        }
        
        scrollDirection = .vertical
        minimumLineSpacing = 10
        minimumInteritemSpacing = 10
        sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        let width = ((cv.frame.width - 40) / 3).rounded(.down)
        itemSize = CGSize(width: width, height: width)
    }
}
