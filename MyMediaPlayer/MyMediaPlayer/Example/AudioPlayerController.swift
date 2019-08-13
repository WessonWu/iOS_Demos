//
//  AudioPlayerController.swift
//  MyMediaPlayer
//
//  Created by wuweixin on 2019/8/13.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit

class AudioPlayerController: CompatibleViewController {
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
        pushAnotherVCButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        pushAnotherVCButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        
        pushAnotherVCButton.addTarget(self, action: #selector(pushAnotherVC), for: .touchUpInside)
        
        interactiveTransition.prepare(for: self)
    }
    
    
    
    // override MLeaksFinder's willDealloc method
    @objc dynamic func willDealloc() -> Bool {
        return false
    }
    
    
    @objc
    func pushAnotherVC() {
        print(#function)
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
