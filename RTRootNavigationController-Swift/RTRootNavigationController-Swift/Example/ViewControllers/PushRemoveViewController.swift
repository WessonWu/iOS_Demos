//
//  PushRemoveViewController.swift
//  RTRootNavigationController-Swift
//
//  Created by wuweixin on 2019/7/28.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit

class PushRemoveViewController: UIViewController {
    @IBOutlet weak var animationSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onPush(_ sender: Any) {
        self.rt.navigationController?.pushViewController(DisableInteractivePopViewController(),
        animated: animationSwitch.isOn, completion: { [weak self] (_) in
            guard let vc = self else {
                return
            }
            vc.rt.navigationController?.removeViewController(vc)
        })
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
