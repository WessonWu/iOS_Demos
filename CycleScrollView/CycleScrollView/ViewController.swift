//
//  ViewController.swift
//  CycleScrollView
//
//  Created by wuweixin on 2019/6/10.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit
import Kingfisher

class ViewController: UIViewController {
    
    var images: [URL] = []
    
    
    lazy var collectionView: UICollectionView = UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: CycleScrollFlowLayout())
    
    override func loadView() {
        super.loadView()
        
        collectionView.frame = CGRect(x: 0, y: 88, width: self.view.bounds.width, height: 200)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        self.view.addSubview(collectionView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        collectionView.backgroundColor = UIColor.cyan
        collectionView.register(CycleScrollViewItemCell.self, forCellWithReuseIdentifier: CycleScrollViewItemCell.reuseIdentifier)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = .fast
        collectionView.dataSource = self
        collectionView.delegate = self
        
        
        images = [URL(string: "http://pic37.nipic.com/20140113/8800276_184927469000_2.png")!,
                  URL(string: "http://k.zol-img.com.cn/sjbbs/7692/a7691515_s.jpg")!,
                  URL(string: "http://pic15.nipic.com/20110628/1369025_192645024000_2.jpg")!,
                  URL(string: "http://pic18.nipic.com/20120204/8339340_144203764154_2.jpg")!,
                  URL(string: "http://pic40.nipic.com/20140331/9469669_142840860000_2.jpg")!]
    }
}

extension ViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CycleScrollViewItemCell.reuseIdentifier, for: indexPath) as! CycleScrollViewItemCell
        let imageURL = images[indexPath.item]
        cell.imageView.kf.setImage(with: imageURL)
        return cell
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        return proposedContentOffset
    }
}

