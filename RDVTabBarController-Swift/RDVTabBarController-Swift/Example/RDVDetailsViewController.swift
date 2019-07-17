//
//  RDVDetailsViewController.swift
//  RDVTabBarController-Swift
//
//  Created by wuweixin on 2019/7/17.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit

class RDVDetailsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = "Details"
        self.view.backgroundColor = UIColor.white
        
        let label = UILabel()
        label.text = "Detail View Controller"
        label.frame = CGRect(x: 20, y: 150, width: self.view.frame.width - 2 * 20, height: 20)
        label.autoresizingMask = .flexibleWidth
        label.textAlignment = .center
        self.view.addSubview(label)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.rdv_tabBarController?.setTabBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.rdv_tabBarController?.setTabBarHidden(false, animated: animated)
        
        super.viewWillDisappear(animated)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
