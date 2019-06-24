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
    @IBOutlet weak var carouselView: CarouselView!
    var images: [URL] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        images = [URL(string: "http://pic37.nipic.com/20140113/8800276_184927469000_2.png")!]
        
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.images = [URL(string: "http://pic37.nipic.com/20140113/8800276_184927469000_2.png")!,
                           URL(string: "http://k.zol-img.com.cn/sjbbs/7692/a7691515_s.jpg")!]
            self.carouselView.reloadData()
        }
    }
}

extension ViewController: CarouselDataSource {
    func numberOfItems(in carouselView: CarouselView) -> Int {
        return images.count
    }
    
    func carouselView(_ carouselView: CarouselView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = carouselView.dequeueReusableCell(withReuseIdentifier: CycleScrollViewItemCell.reuseIdentifier, for: indexPath) as! CycleScrollViewItemCell
        let index = indexPath.item
        let imageURL = images[index]
        cell.imageView.kf.setImage(with: imageURL)
        return cell
    }
}

extension ViewController: CarouselDelegate {
    func carouselView(_ carouselView: CarouselView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.item
        print("selected: \(index)")
        
        let vc = SecondViewController()
        vc.title = "SecondVC: \(index)"
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
