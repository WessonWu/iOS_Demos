//
//  ViewController.swift
//  CircleSlider
//
//  Created by wuweixin on 2019/6/25.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    lazy var slider = CircleSlider()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        slider.trackRadius = 64
        slider.trackLineWidth = 20
        slider.progress = 0.25
        slider.backgroundColor = UIColor.cyan
        self.view.addSubview(slider)
        
        slider.translatesAutoresizingMaskIntoConstraints = false
        let centerX = slider.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        let centerY = slider.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        NSLayoutConstraint.activate([centerX, centerY])
    }
    
    
}

