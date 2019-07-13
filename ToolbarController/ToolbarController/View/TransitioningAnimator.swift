//
//  TransitioningAnimator.swift
//  ToolbarController
//
//  Created by wuweixin on 2019/7/13.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit

enum AnimatorType: Int {
    case present
    case dismiss
}

class TransitioningAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let type: AnimatorType
    init(type: AnimatorType) {
        self.type = type
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to) else {
            return
        }
        
        let containerView = transitionContext.containerView

        switch type {
        case .present:
            fromVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            fromVC.view.frame = containerView.frame
            containerView.addSubview(fromVC.view)
            toVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            toVC.view.frame = containerView.frame
            containerView.addSubview(toVC.view)
            toVC.view.transform = CGAffineTransform(translationX: 0, y: containerView.frame.height)
            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .curveEaseInOut, animations: {
                toVC.view.transform = .identity
            }) { (_) in
                transitionContext.completeTransition(true)
            }
        case .dismiss:
            toVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            toVC.view.frame = containerView.frame
            containerView.addSubview(toVC.view)
            fromVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            fromVC.view.frame = containerView.frame
            containerView.addSubview(fromVC.view)
            fromVC.view.transform = .identity
            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .curveEaseInOut, animations: {
                fromVC.view.transform = CGAffineTransform(translationX: 0, y: containerView.frame.height)
            }) { (_) in
                transitionContext.completeTransition(true)
            }
        }
    }
}
