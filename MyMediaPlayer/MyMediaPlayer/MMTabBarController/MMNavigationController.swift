//
//  MMNavigationController.swift
//  MyMediaPlayer
//
//  Created by wuweixin on 2019/7/20.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit


public class MMNavigationController: UINavigationController {
    
//    lazy var navigationStackView: MMNavigationStackView = MMNavigationStackView()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
//        self.view.addSubview(navigationStackView)
        self.navigationBar.isTranslucent = true
        self.navigationBar.isHidden = true
        self.delegate = self
        self.interactivePopGestureRecognizer?.delegate = self
    }
    
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        navigationStackView.frame = navigationBar.frame
    }
    
    
    func transition(fromViewController: UIViewController?, toViewController: UIViewController) {
        if let fromVC = fromViewController {
            let fromNavigationBar = fromVC.mm_navigationBar
            fromNavigationBar.removeFromSuperview()
            fromVC.view.addSubview(fromNavigationBar)
        }
        
        let toNavigationBar = toViewController.mm_navigationBar
        toNavigationBar.removeFromSuperview()
        toViewController.view.addSubview(toNavigationBar)
        
        let completion: () -> Void = {
            if let topNavigationBar = self.topViewController?.mm_navigationBar {
                self.view.addSubview(topNavigationBar)
            }
        }
        
        if let transitionCoordinator = toViewController.transitionCoordinator {
            transitionCoordinator.animate(alongsideTransition: nil) { (context) in
                completion()
            }
        } else {
            completion()
        }
    }
}


extension MMNavigationController: UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        transition(fromViewController: viewController.transitionCoordinator?.viewController(forKey: .from), toViewController: viewController)
    }
    
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
    }
    
    public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
    
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
}

extension MMNavigationController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
