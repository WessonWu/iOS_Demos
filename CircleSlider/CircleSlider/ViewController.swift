//
//  ViewController.swift
//  CircleSlider
//
//  Created by wuweixin on 2019/6/25.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    lazy var slider = ParentLocker()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        slider.trackRadius = 64
        slider.trackLineWidth = 20
        slider.minimumValue = 0
        slider.maximumValue = 360
        slider.backgroundColor = UIColor.cyan
        self.view.addSubview(slider)
        
        slider.translatesAutoresizingMaskIntoConstraints = false
        let centerX = slider.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        let centerY = slider.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        NSLayoutConstraint.activate([centerX, centerY])
        
        slider.addTarget(self, action: #selector(progressValueChanged(_:)), for: .valueChanged)
        slider.addTarget(self, action: #selector(touchDown(_:)), for: .touchDown)
        slider.addTarget(self, action: #selector(touchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    
    @objc
    private func progressValueChanged(_ sender: CircleSlider) {
        print(#function, sender.currentValue)
    }
    
    
    @objc
    private func touchDown(_ sender: CircleSlider) {
        print(#function)
    }
    
    
    @objc
    private func touchUp(_ sender: CircleSlider) {
        if sender.currentValue < 360 {
            UIView.animate(withDuration: 0.35) {
                sender.currentValue = 0
            }
        } else {
            print("完成")
        }
    }
}

