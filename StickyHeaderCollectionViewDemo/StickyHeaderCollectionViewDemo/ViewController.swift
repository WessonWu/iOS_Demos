//
//  ViewController.swift
//  StickyHeaderCollectionViewDemo
//
//  Created by wuweixin on 2019/8/10.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var headerView: UIImageView!
    @IBOutlet weak var collectionView: StickyHeaderCollectionView!
    @IBOutlet weak var navigationView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        collectionView.contentInsetTopForHeaderView = 160
        collectionView.headerView = headerView
        collectionView.scrollUpwardPercentCallback = { [weak self] (percent) in
            guard let navigationView = self?.navigationView else {
                return
            }
            navigationView.backgroundColor = navigationView.backgroundColor?.withAlphaComponent(percent)
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.scrollUpwardEdgeInsetTop = navigationView.frame.height
    }

}

extension ViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 50
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        if let label = cell.contentView.viewWithTag(100) as? UILabel {
            label.text = "Item: \(indexPath.item)"
        }
        return cell
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
}

