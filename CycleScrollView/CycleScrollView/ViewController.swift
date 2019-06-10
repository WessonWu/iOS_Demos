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
    
    var autoScrollTimer: Timer?
    
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
        
        scrollToCenterAt(index: 0, animated: false)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fireAutoScrollTimer()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        invalidateAutoScrollTimer()
    }
    
    
    func scrollToCenterAt(index: Int, animated: Bool) {
        let indexPath = IndexPath(item: index, section: collectionView.numberOfSections / 2)
        guard indexPath.section < collectionView.numberOfSections
            && indexPath.item < collectionView.numberOfItems(inSection: indexPath.section) else {
            return
        }
        
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
    }
    
    
    @objc
    private func autoScrollTick() {
        let bounds = collectionView.bounds
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        guard let indexPath = collectionView.indexPathForItem(at: center) else {
            return
        }
        
        let numberOfSections = collectionView.numberOfSections
        let numberOfItems = collectionView.numberOfItems(inSection: indexPath.section)
        let section = (indexPath.section + (indexPath.item + 1) / numberOfItems) % numberOfSections
        let item = (indexPath.item + 1) % collectionView.numberOfItems(inSection: section)
        
        collectionView.scrollToItem(at: IndexPath(item: item, section: section), at: .centeredHorizontally, animated: true)
    }
    
    
    private func fireAutoScrollTimer() {
        guard self.autoScrollTimer == nil else {
            return
        }
        let timer = Timer(timeInterval: 3,
                         target: self,
                         selector: #selector(autoScrollTick),
                         userInfo: nil,
                         repeats: true)
        self.autoScrollTimer = timer
        timer.fireDate = Date(timeIntervalSinceNow: 3)
        RunLoop.main.add(timer, forMode: .common)
    }
    
    private func invalidateAutoScrollTimer() {
        self.autoScrollTimer?.invalidate()
        self.autoScrollTimer = nil
    }
    
    
    private func pauseAutoScrollTimer() {
        self.autoScrollTimer?.fireDate = .distantFuture
    }
    
    private func resumeAutoScrollTimer() {
        self.autoScrollTimer?.fireDate = Date(timeIntervalSinceNow: 3)
    }
}

extension ViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 5
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
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let bounds = scrollView.bounds
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        guard let indexPath = collectionView.indexPathForItem(at: center) else {
            return
        }
        scrollToCenterAt(index: indexPath.item, animated: false)
        
        resumeAutoScrollTimer()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidEndScrollingAnimation(scrollView)
    }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        pauseAutoScrollTimer()
    }
}

