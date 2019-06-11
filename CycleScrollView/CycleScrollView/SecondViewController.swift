//
//  SecondViewController.swift
//  CycleScrollView
//
//  Created by wuweixin on 2019/6/11.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    var images: [URL] = []
    
    lazy var carouselView: CarouselView = CarouselView()
    
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = randomColor()
        
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
        
        carouselView.setupCollectionView { (collectionView) in
            guard let flowLayout = collectionView.collectionViewLayout as? CarouselFlowLayout else {
                return
            }
            
            flowLayout.padding = UIEdgeInsets(top: 8, left: 40, bottom: 8, right: 40)
            flowLayout.spacing = 8
        }
        carouselView.register(CycleScrollViewItemCell.self,
                              forCellWithReuseIdentifier: CycleScrollViewItemCell.reuseIdentifier)
        carouselView.dataSource = self
        carouselView.delegate = self
    }
    
    func randomColor() -> UIColor? {
        let colors: [UIColor] = [.white,
                                 .blue,
                                 .green,
                                 .gray,
                                 .orange,
                                 .yellow,
                                 .purple]
        return colors.randomElement()
    }
}

extension SecondViewController: CarouselDataSource {
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

extension SecondViewController: CarouselDelegate {
    func carouselView(_ carouselView: CarouselView, didSelectItemAt index: Int) {
        print("selected: \(index)")
        
        let vc = SecondViewController()
        vc.title = "SecondVC: \(index)"
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

