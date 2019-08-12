//
//  SwipeDismissTransitionAnimator.swift
//  BunnyEarsMedia
//
//  Created by wuweixin on 2019/7/15.
//  Copyright © 2019 4399. All rights reserved.
//

import UIKit

class SwipeTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to) else {
                return
        }
        
        let containerView = transitionContext.containerView
        
        let isPresenting = toVC.presentingViewController == fromVC
        let fromFrame = transitionContext.initialFrame(for: fromVC)
        let toFrame = transitionContext.finalFrame(for: toVC)
        
        let fromView: UIView
        let toView: UIView
        
        if let fv = transitionContext.view(forKey: .from) {
            fromView = fv
        } else {
            fromView = fromVC.view
        }
        
        if let tv = transitionContext.view(forKey: .to) {
            toView = tv
        } else {
            toView = toVC.view
        }
        
        if isPresenting {
            fromView.frame = fromFrame
            toView.frame = toFrame.offsetBy(dx: 0, dy: toFrame.height)
        } else {
            fromView.frame = fromFrame
            toView.frame = toFrame
        }
        
        if isPresenting {
            containerView.addSubview(toView)
        } else {
            containerView.insertSubview(toView, belowSubview: fromView)
        }
        
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: duration, animations: {
            if isPresenting {
                toView.frame = toFrame
            } else {
                fromView.frame = fromFrame.offsetBy(dx: 0, dy: fromFrame.height)
            }
        }) { (finished) in
            let wasCancelled = transitionContext.transitionWasCancelled
            
            if wasCancelled {
                toView.removeFromSuperview()
            }
            
            transitionContext.completeTransition(!wasCancelled)
        }
    }
}
