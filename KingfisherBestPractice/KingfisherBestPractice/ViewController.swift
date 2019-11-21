//
//  ViewController.swift
//  KingfisherBestPractice
//
//  Created by wuweixin on 2019/11/21.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit
import Kingfisher

class ViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    let urls: [URL] = [URL(string: "http://mobi.4399tech.com/redirect/tuer/otres/source/gif/1911/759_square_pic_16c35fa857.gif")!,
                       URL(string: "http://mobi.4399tech.com/redirect/tuer/otres/source/gif/1909/743_square_pic_b1e393cf87.gif")!,
                       URL(string: "http://mobi.4399tech.com/redirect/tuer/otres/source/gif/1907/594_square_pic_d6b94d702d.gif")!,
                       URL(string: "http://mobi.4399tech.com/redirect/tuer/otres/source/gif/1905/594_square_pic_2e4c38fc6e.gif")!,
                       URL(string: "http://mobi.4399tech.com/redirect/tuer/otres/source/gif/1903/594_square_pic_b6ae9b3472.gif")!,
                       URL(string: "http://mobi.4399tech.com/redirect/tuer/otres/source/gif/1911/759_square_pic_cd4ae20a55.gif")!,
                       URL(string: "http://mobi.4399tech.com/redirect/tuer/otres/source/gif/1911/759_square_pic_753d84c33e.gif")!,
                       URL(string: "http://mobi.4399tech.com/redirect/tuer/otres/source/gif/1909/759_square_pic_af4b1bba46.gif")!,
                       URL(string: "http://mobi.4399tech.com/redirect/tuer/otres/source/gif/1909/759_square_pic_0050020667.gif")!]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}

extension ViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 500
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        let count = urls.count
        let url = urls[indexPath.item % count]
        // 第一个版本
        cell.imageView.kf.setImage(with: url, placeholder: nil, options: [], progressBlock: nil, completionHandler: nil)
        return cell
    }
}
