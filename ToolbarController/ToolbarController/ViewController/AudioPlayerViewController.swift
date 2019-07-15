//
//  AudioPlayerViewController.swift
//  ToolbarController
//
//  Created by wuweixin on 2019/7/13.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit

class AudioPlayerViewController: UIViewController {
    
    lazy var dismissButton: UIButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.cyan
        // Do any additional setup after loading the view.
        dismissButton.setTitle("dismiss", for: .normal)
        self.view.addSubview(dismissButton)
        
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        dismissButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        
        dismissButton.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
    @objc
    private func dismissSelf() {
        self.navigationController?.popViewController(animated: true)
    }
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
