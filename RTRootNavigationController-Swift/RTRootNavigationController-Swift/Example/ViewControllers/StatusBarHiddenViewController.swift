//
//  StatusBarHiddenViewController.swift
//  RTRootNavigationController-Swift
//
//  Created by wuweixin on 2019/7/29.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit

class StatusBarHiddenViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
}
