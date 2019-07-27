//
//  DisableInteractivePopViewController.swift
//  RTRootNavigationController-Swift
//
//  Created by wuweixin on 2019/7/27.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit

class DisableInteractivePopViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = "Test VC"
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = UIColor.blue
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    

    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    

}

extension DisableInteractivePopViewController: RTNavigationItemCustomizable {
    func customBackItemWithTarget(_ target: Any?, action: Selector) -> UIBarButtonItem? {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "back"), for: .normal)
        button.sizeToFit()
        button.addTarget(target, action: action, for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }
}
