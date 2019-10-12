//
//  PagerContainerViewController.swift
//  StickyHeaderViewDemo
//
//  Created by wuweixin on 2019/8/12.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit

open class PagerContainerController: UIViewController, UIScrollViewDelegate {
    
    public lazy var containerView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.bounces = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.scrollsToTop = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        return scrollView
    }()
    
    open private(set) var viewControllers = [UIViewController]()
    open private(set) var currentIndex = 0
    open private(set) var preCurrentIndex = 0 // used *only* to store the index to which move when the pager becomes visible
    
    open var pageWidth: CGFloat {
        return containerView.bounds.width
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.frame = view.bounds
        view.addSubview(containerView)
        
        if #available(iOS 11.0, *) {
            containerView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        reloadViewControllers()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isViewAppearing = true
        children.forEach { $0.beginAppearanceTransition(true, animated: animated) }
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        lastSize = containerView.bounds.size
        updateIfNeeded()
        let needToUpdateCurrentChild = preCurrentIndex != currentIndex
        if needToUpdateCurrentChild {
            moveToViewController(at: preCurrentIndex)
        }
        isViewAppearing = false
        children.forEach { $0.endAppearanceTransition() }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        children.forEach { $0.beginAppearanceTransition(false, animated: animated) }
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        children.forEach { $0.endAppearanceTransition() }
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateIfNeeded()
    }
    
    open override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        return false
    }
    
    open func moveToViewController(at index: Int, animated: Bool = true) {
        guard isViewLoaded && view.window != nil && currentIndex != index else {
            preCurrentIndex = index
            return
        }
        
        (navigationController?.view ?? view).isUserInteractionEnabled = !animated
        containerView.setContentOffset(CGPoint(x: pageOffsetForChild(at: index), y: 0), animated: animated)
    }
    
    open func moveTo(viewController: UIViewController, animated: Bool = true) {
        guard let index = viewControllers.firstIndex(of: viewController) else {
            return
        }
        moveToViewController(at: index, animated: animated)
    }
    
    open func viewControllers(for pagerContainerController: PagerContainerController) -> [UIViewController] {
        assertionFailure("Sub-class must implement the PagerTabStripDataSource viewControllers(for:) method")
        return []
    }
    
    // MARK: - Helpers
    
    open func updateIfNeeded() {
        if isViewLoaded && !lastSize.equalTo(containerView.bounds.size) {
            updateContent()
        }
    }
    
    open func canMoveTo(index: Int) -> Bool {
        return currentIndex != index && viewControllers.count > index
    }
    
    open func pageOffsetForChild(at index: Int) -> CGFloat {
        return CGFloat(index) * containerView.bounds.width
    }
    
    open func offsetForChild(at index: Int) -> CGFloat {
        return (CGFloat(index) * containerView.bounds.width) + ((containerView.bounds.width - view.bounds.width) * 0.5)
    }
    
    open func pageFor(contentOffset: CGFloat) -> Int {
        let result = virtualPageFor(contentOffset: contentOffset)
        return pageFor(virtualPage: result)
    }
    
    open func virtualPageFor(contentOffset: CGFloat) -> Int {
        return Int((contentOffset + 1.5 * pageWidth) / pageWidth) - 1
    }
    
    open func pageFor(virtualPage: Int) -> Int {
        if virtualPage < 0 {
            return 0
        }
        if virtualPage > viewControllers.count - 1 {
            return viewControllers.count - 1
        }
        return virtualPage
    }
    
    open func updateContent() {
        if lastSize.width != containerView.bounds.size.width {
            lastSize = containerView.bounds.size
            containerView.contentOffset = CGPoint(x: pageOffsetForChild(at: currentIndex), y: 0)
        }
        lastSize = containerView.bounds.size
        
        let pagerViewControllers = self.viewControllers
        containerView.contentSize = CGSize(width: containerView.bounds.width * CGFloat(pagerViewControllers.count),
                                           height: containerView.contentSize.height)
        
        for (index, childController) in pagerViewControllers.enumerated() {
            if childController.parent != nil {
                childController.view.frame = CGRect(x: offsetForChild(at: index),
                                                    y: 0,
                                                    width: view.bounds.width,
                                                    height: containerView.bounds.height)
                childController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            } else {
                addChild(childController)
                childController.view.frame = CGRect(x: offsetForChild(at: index),
                                                    y: 0,
                                                    width: view.bounds.width,
                                                    height: containerView.bounds.height)
                childController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
                containerView.addSubview(childController.view)
                childController.didMove(toParent: self)
            }
        }
        
        let virtualPage = virtualPageFor(contentOffset: containerView.contentOffset.x)
        let newCurrentIndex = pageFor(virtualPage: virtualPage)
        currentIndex = newCurrentIndex
        preCurrentIndex = currentIndex
    }
    
    // MARK: - UIScrollViewDelegate
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if containerView == scrollView {
            updateContent()
            lastContentOffset = scrollView.contentOffset.x
        }
    }
    
    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if containerView == scrollView {
            (navigationController?.view ?? view).isUserInteractionEnabled = true
            updateContent()
        }
    }
    
    // MARK: - Orientation
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        isViewRotating = true
        pageBeforeRotate = currentIndex
        coordinator.animate(alongsideTransition: nil) { [weak self] _ in
            guard let me = self else { return }
            me.isViewRotating = false
            me.currentIndex = me.pageBeforeRotate
            me.preCurrentIndex = me.currentIndex
            me.updateIfNeeded()
        }
    }
    
    // MARK: Private
    private func reloadViewControllers() {
        viewControllers = self.viewControllers(for: self)
        updateIfNeeded()
    }
    
    private var lastContentOffset: CGFloat = 0.0
    private var pageBeforeRotate = 0
    private var lastSize = CGSize(width: 0, height: 0)
    internal var isViewRotating = false
    internal var isViewAppearing = false
    
}

