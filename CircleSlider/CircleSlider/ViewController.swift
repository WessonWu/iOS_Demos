//
//  ViewController.swift
//  CircleSlider
//
//  Created by wuweixin on 2019/6/25.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var resultLabel: UILabel!
    
    lazy var slider = ParentLocker()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
        if sender.currentValue >= 360 {
            self.resultLabel.text = "解锁成功"
        }
    }
    
    
    @objc
    private func touchDown(_ sender: CircleSlider) {
        print(#function)
    }
    
    
    @objc
    private func touchUp(_ sender: CircleSlider) {
        if sender.currentValue < 360 {
            let delta = sender.currentValue / 360 * 0.2
            let duration = 0.2 + delta
            UIView.animate(withDuration: TimeInterval(duration)) {
                sender.currentValue = 0
            }
            self.resultLabel.text = "解锁失败"
        } else {
            self.resultLabel.text = "解锁成功"
        }
    }
}

