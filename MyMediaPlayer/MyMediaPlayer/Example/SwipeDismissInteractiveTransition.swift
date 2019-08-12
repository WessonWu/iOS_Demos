//
//  SwipeDismissInteractiveTransition.swift
//  BunnyEarsMedia
//
//  Created by wuweixin on 2019/7/15.
//  Copyright © 2019 4399. All rights reserved.
//

import UIKit
#if DEBUG
extension UIGestureRecognizer.State: CustomStringConvertible {
    public var description: String {
        switch self {
        case .possible:
            return "possible"
        case .began:
            return "began"
        case .changed:
            return "changed"
        case .ended:
            return "ended"
        case .cancelled:
            return "cancelled"
        case .failed:
            return "failed"
        default:
            return "others"
        }
    }
}
#endif

class SwipeDismissInteractiveTransition: UIPercentDrivenInteractiveTransition {
    weak var viewController: UIViewController?
    lazy var interactiveGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleGestureRecognizer(_:)))
    
    private var fractionDenominator: CGFloat = UIScreen.main.bounds.height
    
    private(set) var isInteracting: Bool = false
    private var shouldComplete: Bool = false
    
    func prepare(for viewController: UIViewController) {
        self.viewController = viewController
        interactiveGestureRecognizer.delegate = self
        viewController.view.addGestureRecognizer(interactiveGestureRecognizer)
    }
    
    @objc
    private func handleGestureRecognizer(_ gesture: UIPanGestureRecognizer) {
        guard let vc = self.viewController else {
            return
        }
        switch gesture.state {
        case .began:
            self.isInteracting = true
            vc.dismiss(animated: true, completion: nil)
        case .changed:
            let translation = gesture.translation(in: gesture.view)
            var fraction = translation.y / fractionDenominator
            fraction = min(max(0, fraction), 1)
            self.shouldComplete = fraction > 0.4
            update(fraction * 0.8)
        case .ended, .cancelled:
            self.isInteracting = false
            if shouldComplete {
                finish()
                return
            }
            let velocity = gesture.velocity(in: gesture.view)
            if velocity.y > 400 {
                finish()
            } else {
                cancel()
            }
        default:
            break
        }
    }
}

extension SwipeDismissInteractiveTransition: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let gesture = gestureRecognizer as? UIPanGestureRecognizer else {
            return false
        }
        
        let translation = gesture.translation(in: gesture.view)
        return translation.y > 0
    }
}
