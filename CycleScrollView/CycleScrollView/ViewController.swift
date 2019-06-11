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
    
    
    lazy var carouselView: CarouselView = CarouselView()
    
    override func loadView() {
        super.loadView()
        
        carouselView.frame = CGRect(x: 0, y: 88, width: self.view.bounds.width, height: 200)
        carouselView.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        self.view.addSubview(carouselView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        carouselView.backgroundColor = UIColor.cyan
        images = [URL(string: "http://pic37.nipic.com/20140113/8800276_184927469000_2.png")!,
                  URL(string: "http://k.zol-img.com.cn/sjbbs/7692/a7691515_s.jpg")!,
                  URL(string: "http://pic15.nipic.com/20110628/1369025_192645024000_2.jpg")!,
                  URL(string: "http://pic18.nipic.com/20120204/8339340_144203764154_2.jpg")!,
                  URL(string: "http://pic40.nipic.com/20140331/9469669_142840860000_2.jpg")!]
        carouselView.collectionView.register(CycleScrollViewItemCell.self,
                                             forCellWithReuseIdentifier: CycleScrollViewItemCell.reuseIdentifier)
        carouselView.dataSource = self
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        carouselView.startAutoScroller()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        carouselView.stopAutoScroller()
    } 
}

extension ViewController: CarouselDataSource {
    func numberOfItems(in carouselView: CarouselView) -> Int {
        return images.count
    }
    
    func carouselView(_ carouselView: CarouselView, cellForItemAt index: Int) -> UICollectionViewCell {
        let cell = carouselView.dequeueReusableCell(withReuseIdentifier: CycleScrollViewItemCell.reuseIdentifier, for: index) as! CycleScrollViewItemCell
        let imageURL = images[index]
        cell.imageView.kf.setImage(with: imageURL)
        return cell
    }
}

