//
//  AudioPlayerController.swift
//  MyMediaPlayer
//
//  Created by wuweixin on 2019/8/13.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit

public protocol PresentedViewControllerPushable: UIViewController {}

class AudioPlayerController: CompatibleViewController, PresentedViewControllerPushable {
    static let shared: AudioPlayerController = sharedInit()
    
    lazy var interactiveTransition: SwipeDismissInteractiveTransition = SwipeDismissInteractiveTransition()
    
    lazy var pushAnotherVCButton: UIButton = UIButton(type: .system)
    
    private class func sharedInit() -> AudioPlayerController {
        let vc = AudioPlayerController()
        vc.transitioningDelegate = vc
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = UIColor.cyan
        pushAnotherVCButton.setTitle("Push", for: .normal)
        pushAnotherVCButton.setTitleColor(UIColor.blue, for: .normal)
        
        self.view.addSubview(pushAnotherVCButton)
        pushAnotherVCButton.translatesAutoresizingMaskIntoConstraints = false
        pushAnotherVCButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        pushAnotherVCButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        
        pushAnotherVCButton.addTarget(self, action: #selector(pushAnotherVC), for: .touchUpInside)
        
        interactiveTransition.prepare(for: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.pendingPresentingViewController?.pendingPresentedViewController = nil
    }
    
    
    
    // override MLeaksFinder's willDealloc method
    @objc dynamic func willDealloc() -> Bool {
        return false
    }
    
    
    @objc
    func pushAnotherVC() {
        print(#function)
        
        
        guard let topMostViewController = UIApplication.shared.topMostViewController() else {
            return
        }
        
        print(topMostViewController)
        
        UIApplication.shared.pushViewControllerAsPossible(DetailsViewController.newInstance())
    }
}

extension AudioPlayerController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SwipeTransitionAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SwipeTransitionAnimator()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveTransition.isInteracting ? interactiveTransition : nil
    }
}




public extension UIApplication {
    func topMostViewController(for viewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = viewController as? UINavigationController {
            return topMostViewController(for: navigationController.visibleViewController)
        }
        if let tabBarController = viewController as? UITabBarController {
            if let selectedViewController = tabBarController.selectedViewController {
                return topMostViewController(for: selectedViewController)
            }
        }
        if let splitViewController = viewController as? UISplitViewController {
            if let lastVC = splitViewController.viewControllers.last {
                return topMostViewController(for: lastVC)
            }
        }
        if let presentedViewController = viewController?.presentedViewController {
            return topMostViewController(for: presentedViewController)
        }
        return viewController
    }
    
    
    func pushViewControllerAsPossible(_ viewController: UIViewController, animated: Bool = true) {
        guard let topMostVC = self.topMostViewController() else {
            return
        }
        
        if let navigationController = topMostVC.navigationController {
            navigationController.pushViewController(viewController, animated: animated)
            return
        }
        
        if let _ = topMostVC as? PresentedViewControllerPushable,
            let navigationController = topMostVC.presentingViewController?.topMostNavigaitonController() {
            navigationController.topViewController?.pendingPresentedViewController = topMostVC
            topMostVC.dismiss(animated: false) {
                navigationController.pushViewController(viewController, animated: animated)
            }
        }
    }
}

public extension UIViewController {
    func topMostNavigaitonController() -> UINavigationController? {
        if let navigationController = self as? UINavigationController {
            return navigationController
        }
        if let navigationController = self.navigationController {
            return navigationController
        }
        if let tabBarController = self as? UITabBarController {
            return tabBarController.selectedViewController?.topMostNavigaitonController()
        }
        if let splitViewController = self as? UISplitViewController {
            return splitViewController.viewControllers.last?.topMostNavigaitonController()
        }
        return nil
    }
}
