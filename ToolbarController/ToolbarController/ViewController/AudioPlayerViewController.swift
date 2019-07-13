//
//  AudioPlayerViewController.swift
//  ToolbarController
//
//  Created by wuweixin on 2019/7/13.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit

class AudioPlayerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.cyan
        // Do any additional setup after loading the view.
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.navigationController?.setNavigationBarHidden(true, animated: animated)
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


extension AudioPlayerViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push:
            return TransitioningAnimator(type: .present)
        case .pop:
            return TransitioningAnimator(type: .dismiss)
        default:
            return nil
        }
    }
}
