//
//  ViewController.swift
//  WebPDemo
//
//  Created by wuweixin on 2020/4/26.
//  Copyright © 2020 weixinwu. All rights reserved.
//

import UIKit
import WebKit
import Kingfisher
import KingfisherWebP

/**
 Reference from https://developers.google.com/speed/webp/gallery?hl=zh-cn
 client webp url: https://www.gstatic.com/webp/gallery/4.sm.webp?dcb_=0.40009090765093513
 WKWebVIew webp url: https://www.gstatic.com/webp/gallery/1.webp
 */

class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    
    lazy var webView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        let frame = CGRect(x: 0, y: 0, width: 375, height: 812)
        let webView = WKWebView(frame: frame, configuration: configuration)
        return webView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // add webview
        self.view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            webView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            webView.widthAnchor.constraint(equalToConstant: 200),
            webView.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        
        // request webp
        let options: KingfisherOptionsInfo = [
            .processor(WebPProcessor.default),
            .cacheSerializer(WebPSerializer.default)
        ]
        self.imageView.kf.setImage(
            with: URL(string: "https://www.gstatic.com/webp/gallery/4.sm.webp?dcb_=0.40009090765093513"),
            options: options
        )
        
        if let fileURL = Bundle.main.url(forResource: "webp", withExtension: "html") {
            webView.load(URLRequest(url: fileURL))
        }
    }


}

