//
//  ViewController.swift
//  MultiXcodeConfiguration
//
//  Created by wuweixin on 2019/12/16.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    @IBOutlet weak var networkLabel: UILabel!
    @IBOutlet weak var productLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        #if PRODUCTION
        productLabel.text = "Production"
        #endif
        
        #if DEVELOPMENT
        productLabel.text = "Development"
        #endif
        
        #if TEST
        networkLabel.text = "Test"
        #endif
        
        #if ONLINE
        networkLabel.text = "Online"
        #endif
        
        request(URL(string: "https://help.apple.com/xcode/mac/10.2/#/dev745c5c974")!, method: .get, parameters: nil, encoding: URLEncoding(), headers: nil).responseData { (resp) in
            print(resp)
        }
        
        print(Bundle.main.bundleIdentifier)
    }


}

