//
//  ViewController.swift
//  KingfisherBestPractice
//
//  Created by wuweixin on 2019/11/21.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit
import Kingfisher

/*
 优化建议：
 1、取消不必要的downloadTask，在列表didEndDisplayCell回调函数中调用cell.imageView.kf.cancelDownloadTask()
 2、需要使用圆角图片的时候，有以下建议(降低离屏渲染)：
    2.1、直接将图片处理成圆角(推荐)
    2.2、在ImageView上覆盖一层中间透明四周圆角不为透明的图片或View(例如：RoundImageView)
 3、使用ImagePlaceholder的时候最好使用图片的方式(参考ImagePlaceholderManager)，可以降低CPU利用率
 4、尽量降低页面中gif图的使用，最好更多的使用静态图片(降低内存&提升滚动性能)
 5、使用DownsamplingImageProcessor加载缩略图的方式，降低内存占用(推荐options = [.scaleFactor(scale), .processor(processor), .backgroundDecode, .cacheOriginalImage])
 6、然后布局的时候，尽量减少视图层级；优先级：设置frame > autoresizingMask > AutoLayout (降低CPU利用率)
 */

class ViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    let gifs: [URL] = [URL(string: "http://mobi.4399tech.com/redirect/tuer/otres/source/gif/1911/759_square_pic_16c35fa857.gif")!,
                       URL(string: "http://mobi.4399tech.com/redirect/tuer/otres/source/gif/1909/743_square_pic_b1e393cf87.gif")!,
                       URL(string: "http://mobi.4399tech.com/redirect/tuer/otres/source/gif/1907/594_square_pic_d6b94d702d.gif")!,
                       URL(string: "http://mobi.4399tech.com/redirect/tuer/otres/source/gif/1905/594_square_pic_2e4c38fc6e.gif")!,
                       URL(string: "http://mobi.4399tech.com/redirect/tuer/otres/source/gif/1903/594_square_pic_b6ae9b3472.gif")!,
                       URL(string: "http://mobi.4399tech.com/redirect/tuer/otres/source/gif/1911/759_square_pic_cd4ae20a55.gif")!,
                       URL(string: "http://mobi.4399tech.com/redirect/tuer/otres/source/gif/1911/759_square_pic_753d84c33e.gif")!,
                       URL(string: "http://mobi.4399tech.com/redirect/tuer/otres/source/gif/1909/759_square_pic_af4b1bba46.gif")!,
                       URL(string: "http://mobi.4399tech.com/redirect/tuer/otres/source/gif/1909/759_square_pic_0050020667.gif")!,
                       URL(string: "http://mobi.4399tech.com/redirect/tuer/otres/source/gif/1910/759_square_pic_183177ccf1.gif")!,
                       URL(string: "http://mobi.4399tech.com/redirect/tuer/otres/source/gif/1910/759_square_pic_e68ab1fa63.gif")!,
                       URL(string: "http://mobi.4399tech.com/redirect/tuer/otres/source/gif/1910/759_square_pic_e56960a162.gif")!,
                       URL(string: "http://mobi.4399tech.com/redirect/tuer/otres/source/gif/1910/759_square_pic_3482010a7f.gif")!,
                       URL(string: "http://mobi.4399tech.com/redirect/tuer/otres/source/gif/1910/759_square_pic_df505bff5b.gif")!]
    
    let jpgs: [URL] = [URL(string: "http://mobi.4399tech.com/redirect/tuer/otres/source/pic/1911/759_square_pic_d700732cfb.jpg")!,
                       URL(string: "http://mobi.4399tech.com/redirect/tuer/otres/source/pic/1911/759_logo_06cf431a531574145199.jpg")!,
                       URL(string: "http://mobi.4399tech.com/redirect/tuer/otres/source/pic/1911/759_logo_4e6002f0291573106770.jpg")!,
                       URL(string: "http://mobi.4399tech.com/redirect/tuer/otres/source/pic/1907/759_logo_992ead83131563952810.jpg")!,
                       URL(string: "http://mobi.4399tech.com/redirect/tuer/otres/source/pic/1910/bd157791e3909e9.jpg")!,
                       URL(string: "http://mobi.4399tech.com/redirect/tuer/otres/source/pic/1910/759_square_pic_649baae999.jpg")!,
                       URL(string: "http://mobi.4399tech.com/redirect/tuer/otres/source/pic/1910/759_square_pic_bf9214ba80.jpg")!,
                       URL(string: "http://mobi.4399tech.com/redirect/tuer/otres/source/pic/1910/759_square_pic_9e3e8d9454.png")!,
                       URL(string: "http://mobi.4399tech.com/redirect/tuer/otres/source/pic/1909/433053ceef82189.jpg")!,
                       URL(string: "http://mobi.4399tech.com/redirect/tuer/otres/source/pic/1909/759_square_pic_aaeb2c1c50.png")!,
                       URL(string: "http://mobi.4399tech.com/redirect/tuer/otres/source/pic/1909/785_square_pic_cb4e2e2c34.jpg")!,
                       URL(string: "http://mobi.4399tech.com/redirect/tuer/otres/source/pic/1811/594_square_pic_f304d1a47d.png")!,
                       URL(string: "http://mobi.4399tech.com/redirect/tuer/otres/source/pic/1811/594_square_pic_b36a84ba86.png")!,
                       URL(string: "http://mobi.4399tech.com/redirect/tuer/otres/source/pic/1811/594_logo_2fab09cf2b.png")!]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        KingfisherManager.shared.cache.maxMemoryCost = 1024 * 1024 * 40
        KingfisherManager.shared.cache.maxDiskCacheSize = 1024 * 1024 * 300
        KingfisherManager.shared.defaultOptions = [.scaleFactor(UIScreen.main.scale), .backgroundDecode, .cacheOriginalImage]
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
//        let urls = gifs
        let urls = jpgs
        let count = urls.count
        let url = urls[indexPath.item % count]
        /*
        // 第一个版本
        cell.imageView.kf.setImage(with: url, placeholder: nil, options: [], progressBlock: nil, completionHandler: nil)
        */
        
        // 优化后
        /// 如果要加载gif时，不能使用ImageProcessor(会变成静态图片)，然后backgroundDecode也不起作用，加载gif不宜过多，因为会影响滚动性能
        // 高版本的Kingfisher使用DownsamplingImageProcessor降低内存占用
        let processor = DownsamplingImageProcessor(size: CGSize(width: 80, height: 80))
//        let processor = ResizingImageProcessor(referenceSize: CGSize(width: 80, height: 80), mode: .aspectFill) >> CroppingImageProcessor(size: CGSize(width: 80, height: 80))
        let options: KingfisherOptionsInfo = [.processor(processor)]
//        let options: KingfisherOptionsInfo = []
        let imageView: UIImageView = cell.imageView
        imageView.kf.setImage(with: url,
                              placeholder: ImagePlaceholderManager.shared.placeholderImage(size: CGSize(width: 80, height: 80)),
                              options: options,
                              progressBlock: nil,
                              completionHandler: nil)
        
        // 使用ImagePlaceholder将增加CPU利用率 (大概从32% -> 55%左右)
//        imageView.kf.setImage(with: url,
//                              placeholder: ImagePlaceholder(),
//                              options: options,
//                              progressBlock: nil,
//                              completionHandler: nil)
        return cell
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // 优化网络性能
        if let imageCell = cell as? ImageCell {
            imageCell.imageView.kf.cancelDownloadTask()
        }
    }
}
