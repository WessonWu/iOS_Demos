//
//  转场动画
//  BunnyEarsMedia
//
//  Created by wuweixin on 2018/11/15.
//  Copyright © 2018 4399. All rights reserved.
//

import UIKit


enum MediaTransitionType: Int {
    case present = 0
    case dismiss = 1
}

class MediaTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let type: MediaTransitionType
    init(type: MediaTransitionType) {
        self.type = type
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to) else { return }
        
        let containerView = transitionContext.containerView
        containerView.addSubview(toVC.view)
        let frame = containerView.bounds
        
        let invisibleFrame: CGRect = frame.offsetBy(dx: frame.width, dy: 0)
        
        let parallaxDimmingView = UIView()
        parallaxDimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        
        let shadowView = UIView()
        shadowView.backgroundColor = UIColor.white
        shadowView.layer.shadowOffset = CGSize(width: -3, height: 0)
        shadowView.layer.shadowOpacity = 1
        shadowView.layer.shadowColor = UIColor.black.withAlphaComponent(0.4).cgColor
        shadowView.layer.shadowRadius = 4
        
        switch type {
        case .present:
            containerView.insertSubview(parallaxDimmingView, belowSubview: toVC.view)
            containerView.insertSubview(shadowView, aboveSubview: parallaxDimmingView)
            toVC.view.frame = invisibleFrame
            parallaxDimmingView.frame = frame
            shadowView.frame = invisibleFrame
            parallaxDimmingView.alpha = 0
            shadowView.alpha = 0
            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .curveEaseOut, animations: {
                parallaxDimmingView.alpha = 1
                shadowView.alpha = 1
                toVC.view.frame = frame
                shadowView.frame = frame
            }) { (_) in
                parallaxDimmingView.removeFromSuperview()
                shadowView.removeFromSuperview()
                transitionContext.completeTransition(true)
            }
        case .dismiss:
            containerView.bringSubviewToFront(fromVC.view)
            containerView.insertSubview(parallaxDimmingView, belowSubview: fromVC.view)
            containerView.insertSubview(shadowView, aboveSubview: parallaxDimmingView)
            toVC.view.frame = frame
            parallaxDimmingView.frame = frame
            shadowView.frame = frame
            parallaxDimmingView.alpha = 1
            shadowView.alpha = 1
            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .curveEaseIn, animations: {
                parallaxDimmingView.alpha = 0
                shadowView.alpha = 0
                shadowView.frame = invisibleFrame
                fromVC.view.frame = invisibleFrame
            }) { (_) in
                parallaxDimmingView.removeFromSuperview()
                shadowView.removeFromSuperview()
                fromVC.view.removeFromSuperview()
                transitionContext.completeTransition(true)
            }
        }
    }
}
