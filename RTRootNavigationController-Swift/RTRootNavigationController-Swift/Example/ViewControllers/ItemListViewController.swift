//
//  ItemListViewController.swift
//  RTRootNavigationController-Swift
//
//  Created by wuweixin on 2019/7/28.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class ItemListViewController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.itemSize = CGSize(width: (self.view.bounds.width - 10 * 3) / 2, height: 150)
        }
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        self.navigationController?.delegate = self
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 20
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
    
        return cell
    }

}

extension ItemListViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push {
            return self
        }
        return nil
    }
}

extension ItemListViewController: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to) else {
            return
        }
        
        let containerView = transitionContext.containerView
        
//        let fromView: UIView = transitionContext.view(forKey: .from) ?? fromVC.view
        let toView: UIView = transitionContext.view(forKey: .to) ?? toVC.view
        
        containerView.addSubview(toView)
        
        containerView.setNeedsLayout()
        containerView.layoutIfNeeded()
        
        toView.alpha = 0
        
        var finalFrame: CGRect = .zero
        if let listVC = fromVC.rt.unwrapped as? ItemListViewController,
            let selected = listVC.collectionView.indexPathsForSelectedItems?.first,
            let cell = listVC.collectionView.cellForItem(at: selected),
            let detailVC = toVC.rt.unwrapped as? ItemDetailViewController  {
            finalFrame = detailVC.itemImageView.frame
            detailVC.itemImageView.frame = detailVC.view.convert(cell.frame, from: cell.superview)
        }
        
        UIView.transition(with: containerView, duration: transitionDuration(using: transitionContext), options: .curveEaseInOut, animations: {
            toView.alpha = 1
            if let detailVC = toVC.rt.unwrapped as? ItemDetailViewController {
                detailVC.itemImageView.frame = finalFrame
            }
        }) { (_) in
            if transitionContext.transitionWasCancelled {
                toView.removeFromSuperview()
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
