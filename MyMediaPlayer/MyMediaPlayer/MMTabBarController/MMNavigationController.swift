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
    
    
    func visibleNavigationBarFrame() -> CGRect {
        var originalY: CGFloat = 20
        if #available(iOS 11.0, *) {
            originalY = self.view.safeAreaInsets.top
        }
        return CGRect(x: 0, y: 0, width: navigationBar.frame.width, height: navigationBar.frame.height + originalY)
    }
    
    func addTransitionNavigationBar(to viewController: UIViewController?) {
        guard let vc = viewController else {
            return
        }
        let navigationBar = vc.mm_navigationBar
        if !navigationBar.isHidden {
            navigationBar.removeFromSuperview()
            navigationBar.frame = visibleNavigationBarFrame()
            vc.view.addSubview(navigationBar)
        }
    }
    
    func removeTransitionNavigationBar(from viewController: UIViewController?) {
        guard let vc = viewController else {
            return
        }
        let navigationBar = vc.mm_navigationBar
        if !navigationBar.isHidden {
            navigationBar.removeFromSuperview()
        }
    }
    
    func transition(fromViewController: UIViewController?, toViewController: UIViewController) {
        addTransitionNavigationBar(to: fromViewController)
        addTransitionNavigationBar(to: toViewController)
        
        let completion: () -> Void = {
            self.removeTransitionNavigationBar(from: fromViewController)
            self.removeTransitionNavigationBar(from: toViewController)
            if let topNavigationBar = self.topViewController?.mm_navigationBar {
                topNavigationBar.frame = self.visibleNavigationBarFrame()
                self.view.addSubview(topNavigationBar)
                self.view.layoutIfNeeded()
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
//        transition(fromViewController: viewController.transitionCoordinator?.viewController(forKey: .from), toViewController: viewController)
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
