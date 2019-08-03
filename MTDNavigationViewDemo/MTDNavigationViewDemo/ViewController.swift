//
//  ViewController.swift
//  MTDNavigationViewDemo
//
//  Created by wuweixin on 2019/8/1.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let navigationView = self.mtd.navigationView
//        navigationView.automaticallyAdjustsBackItemHidden = false
//        navigationView.backButton.isHidden = true
        navigationView.backgroundColor = UIColor.red
        navigationView.leftNavigationItemViews = [MTDNavigationImageItemView(image: #imageLiteral(resourceName: "nav_share_ic"), target: self, action: #selector(changeTitle(_:))),
                                                  MTDNavigationImageItemView(image: #imageLiteral(resourceName: "nav_share_ic"), target: self, action: #selector(changeTitle(_:)))]
        navigationView.rightNavigationItemViews = [MTDNavigationImageItemView(image: #imageLiteral(resourceName: "nav_share_ic"), target: self, action: #selector(changeTitle(_:))),
                                                   MTDNavigationImageItemView(image: #imageLiteral(resourceName: "nav_share_ic"), target: self, action: #selector(changeTitle(_:)))]
    }


    @IBAction func changeTitle(_ sender: Any) {
        self.title = "ChangeTitle" + arc4random_uniform(100).description
    }
    
}

