//
//  ViewController.swift
//  LocalOrRemoteNotification
//
//  Created by wuweixin on 2019/7/1.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    
    var text: String? = nil {
        didSet {
            textView?.text = text
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        textView.text = text
        
        URLSession.shared.downloadTask(with: URL(string: "https://img2.woyaogexing.com/2019/10/23/df564e7c3589473088b6ea3a7176b5a4!400x400.jpeg")!) { (tempURL, resp, error) in
            print(tempURL, resp, error)
        }.resume()
    }
}

