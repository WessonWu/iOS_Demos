//
//  AudioPlayerController.swift
//  MyMediaPlayer
//
//  Created by wuweixin on 2019/8/13.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit

class AudioPlayerController: CompatibleViewController, PresentedViewControllerPushable {
    static let shared: AudioPlayerController = sharedInit()
    
    lazy var interactiveTransition: SwipeDismissInteractiveTransition = SwipeDismissInteractiveTransition()
    
    lazy var pushAnotherVCButton: UIButton = UIButton(type: .system)
    lazy var presentVCButton: UIButton = UIButton(type: .system)
    
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
        presentVCButton.setTitle("present", for: .normal)
        presentVCButton.setTitleColor(UIColor.blue, for: .normal)
        
        self.view.addSubview(pushAnotherVCButton)
        self.view.addSubview(presentVCButton)
        pushAnotherVCButton.translatesAutoresizingMaskIntoConstraints = false
        pushAnotherVCButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        pushAnotherVCButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        
        presentVCButton.translatesAutoresizingMaskIntoConstraints = false
        presentVCButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        let centerY = presentVCButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        centerY.constant = 50
        centerY.isActive = true
        
        pushAnotherVCButton.addTarget(self, action: #selector(pushAnotherVC), for: .touchUpInside)
        presentVCButton.addTarget(self, action: #selector(presentVC), for: .touchUpInside)
        
        interactiveTransition.prepare(for: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.mm_pendingPresentingViewController?.mm_pendingPresentedViewController = nil
    }
    
    
    
    // override MLeaksFinder's willDealloc method
    @objc dynamic func willDealloc() -> Bool {
        return false
    }
    
    
    @objc
    func pushAnotherVC() {
        print(#function)
        
        
        let viewControllerToPush = DetailsViewController.newInstance()
//        UIViewController.pushAsPossible(viewControllerToPush, animated: true)
        self.safePush(viewControllerToPush, animated: true)
    }
    
    @objc
    func presentVC() {
        self.safePresent(self) {
            print(#function)
        }
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
