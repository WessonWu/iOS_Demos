//
//  ViewController.swift
//  WebPDemo
//
//  Created by wuweixin on 2020/4/26.
//  Copyright © 2020 weixinwu. All rights reserved.
//

import UIKit
import Kingfisher
import KingfisherWebP

/**
 Reference from https://developers.google.com/speed/webp/gallery?hl=zh-cn
 webp url: https://www.gstatic.com/webp/gallery/4.sm.webp?dcb_=0.40009090765093513
 */

class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        // request webp
        let options: KingfisherOptionsInfo = [
            .processor(WebPProcessor.default),
            .cacheSerializer(WebPSerializer.default)
        ]
        self.imageView.kf.setImage(
            with: URL(string: "https://www.gstatic.com/webp/gallery/4.sm.webp?dcb_=0.40009090765093513"),
            options: options
        )
    }


}

