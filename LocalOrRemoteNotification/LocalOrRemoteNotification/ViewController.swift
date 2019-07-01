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
    
    var userInfo: [AnyHashable: Any]? {
        didSet {
            textView?.text = userInfo?.description
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        textView.text = userInfo?.description
    }
}

