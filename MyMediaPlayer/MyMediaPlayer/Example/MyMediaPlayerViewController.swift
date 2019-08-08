//
//  MyMediaPlayerViewController.swift
//  MyMediaPlayer
//
//  Created by wuweixin on 2019/8/8.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit

class MyMediaPlayerViewController: CompatibleViewController {
    
    class func newInstance() -> MyMediaPlayerViewController {
        let vc = MyMediaPlayerViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.transitioningDelegate = vc
        return vc
    }

    lazy var button = UIButton(type: .system)
    
    /// 页面转场动画是否已经完成 (用于处理转屏)
    var isCompletedAppearTransition: Bool = false
    var supportedInterfaceOrientationsForIphone: UIInterfaceOrientationMask = [.portrait]
    private var isDeterminStatusBarHidden: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.orange

        // Do any additional setup after loading the view.
        self.view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        
        button.setTitle("dismiss", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        
        button.addTarget(self, action: #selector(onDismiss), for: .touchUpInside)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.attemptRotationToDeviceOrientation(with: .landscape)
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let coordinator = self.transitionCoordinator {
            coordinator.animate(alongsideTransition: nil, completion: { [weak self] (ctx) in
                guard !ctx.isCancelled else { return }
                self?.determinStatusBarHidden(true)
                self?.forceRotationToDeviceOrientation()
            })
        } else {
            forceRotationToDeviceOrientation()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let coordinator = self.transitionCoordinator {
            coordinator.animate(alongsideTransition: nil) { (ctx) in
                self.determinStatusBarHidden(false)
                self.attemptRotationToDeviceOrientation(with: .portrait)
            }
        }
    }
    
    /// 返回
    func goBack() {
        /// 先暂停播放
        if let snapshotView = self.view.snapshotView(afterScreenUpdates: false) {
            self.view.subviews.forEach { $0.removeFromSuperview() }
            snapshotView.frame = self.view.bounds
            snapshotView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.view.addSubview(snapshotView)
            
        }
        determinStatusBarHidden(false)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    private func determinStatusBarHidden(_ isDeterminHidden: Bool) {
        self.isDeterminStatusBarHidden = isDeterminHidden
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    
    override var prefersStatusBarHidden: Bool { return isDeterminStatusBarHidden || super.prefersStatusBarHidden }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation { return .none }
    override var shouldAutorotate: Bool { return true }
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return UIDevice.isPad ? [.landscapeLeft, .landscapeRight] : supportedInterfaceOrientationsForIphone
    }
    
    
    @objc
    private func onDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension MyMediaPlayerViewController {
    func attemptRotationToDeviceOrientation(with orientation: UIInterfaceOrientationMask) {
        switch orientation {
        case .portrait:
            supportedInterfaceOrientationsForIphone = [.portrait]
        case .landscape:
            supportedInterfaceOrientationsForIphone = [.landscapeLeft, .landscapeRight]
        default:
            break
        }
        attemptRotationToDeviceOrientation()
    }
    
    func attemptRotationToDeviceOrientation() {
        guard !UIDevice.isPad, isCompletedAppearTransition else { return }
        if supportedInterfaceOrientationsForIphone.contains(.portrait) {
            // 竖屏模式
            if UIDevice.current.orientation.isPortrait || UIApplication.shared.statusBarOrientation.isPortrait {
                UIViewController.attemptRotationToDeviceOrientation()
            } else {
                UIDevice.current.rotate(with: .portrait)
            }
        } else {
            // 横屏模式
            if UIDevice.current.orientation.isLandscape || UIApplication.shared.statusBarOrientation.isLandscape {
                UIViewController.attemptRotationToDeviceOrientation()
            } else {
                UIDevice.current.rotate(with: .landscapeLeft)
            }
        }
    }
    
    func forceRotationToDeviceOrientation() {
        self.isCompletedAppearTransition = true
        DispatchQueue.main.async {
            self.attemptRotationToDeviceOrientation()
        }
    }
}


extension MyMediaPlayerViewController: UIViewControllerTransitioningDelegate {
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return MediaTransitionAnimator(type: .dismiss)
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return MediaTransitionAnimator(type: .present)
    }
}
