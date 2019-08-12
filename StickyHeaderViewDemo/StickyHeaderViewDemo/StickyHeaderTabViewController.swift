//
//  StickyHeaderTabViewController.swift
//  StickyHeaderViewDemo
//
//  Created by wuweixin on 2019/8/11.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import XLPagerTabStrip

class StickyHeaderTabViewController: PagerContainerController {
    
    @IBOutlet var headerView: UIImageView!
    
    lazy var firstVC: TabDetailTableViewController = TabDetailTableViewController()
    lazy var secondVC: TabDetailTableViewController = TabDetailTableViewController()
    
    
    var fixedHeaderHeight: CGFloat = 160
    var tabViewHeight: CGFloat = 44
    
    var detailVCs: [TabDetailTableViewController] {
        return [firstVC, secondVC]
    }
    
    override func viewControllers(for pagerContainerController: PagerContainerController) -> [UIViewController] {
        return detailVCs
    }
    
    var observers: [NSKeyValueObservation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = []
        self.automaticallyAdjustsScrollViewInsets = false
        
        var additionalContentInset: UIEdgeInsets = .zero
        if #available(iOS 11.0, *), let safeAreaInsets = UIApplication.shared.keyWindow?.safeAreaInsets {
            additionalContentInset = safeAreaInsets
        } else {
            additionalContentInset.top = UIApplication.shared.statusBarFrame.height
        }
        self.fixedHeaderHeight += additionalContentInset.top
        self.tabViewHeight += additionalContentInset.top
        
        let headerHeight = self.fixedHeaderHeight
        headerView.frame = CGRect(x: 0,
                                  y: 0,
                                  width: self.view.bounds.width,
                                  height: headerHeight)
        headerView.autoresizingMask = [.flexibleWidth]
        self.view.addSubview(headerView)
        

        
        detailVCs.forEach { (detail) in
            let scrollView: UIScrollView = detail.tableView
            if #available(iOS 11.0, *) {
                scrollView.contentInsetAdjustmentBehavior = .never
            }
            scrollView.contentInset.top = headerHeight
            scrollView.contentInset.bottom = additionalContentInset.bottom
            scrollView.scrollIndicatorInsets.top = headerHeight
            scrollView.scrollIndicatorInsets.bottom = additionalContentInset.bottom
            let observer = scrollView.observe(\.contentOffset, changeHandler: { [weak self] (sv, _) in
                self?.childScrollViewDidScroll(sv)
            })
            self.observers.append(observer)
        }
    }
    
    
    func childScrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        
        let headerHeight = self.fixedHeaderHeight
        let remainHeight = self.tabViewHeight
        let scrollableHeight = headerHeight - remainHeight
        
        var frame = headerView.frame
        var scrollIndicatorInsetTop: CGFloat = headerHeight
        if offsetY < -headerHeight {
            // 超过header高度，拉伸
            let height = -offsetY
            frame.origin.y = 0
            frame.size.height = height
            scrollIndicatorInsetTop = height
        } else {
            frame.origin.y = max(-scrollableHeight, -(offsetY + headerHeight))
            frame.size.height = headerHeight
            scrollIndicatorInsetTop = max(remainHeight, -offsetY)
        }
        headerView.frame = frame
        if scrollView.scrollIndicatorInsets.top != scrollIndicatorInsetTop {
            scrollView.scrollIndicatorInsets.top = scrollIndicatorInsetTop
        }
        
        let subVCs = self.detailVCs
        if frame.origin.y > -scrollableHeight {
            // 当HeaderView跟着滚动时
            subVCs.forEach {
                let temp: UIScrollView = $0.tableView
                guard scrollView != temp, temp.contentOffset.y != offsetY else { return }
                temp.contentOffset.y = offsetY
            }
        } else {
            subVCs.forEach {
                let temp: UIScrollView = $0.tableView
                guard scrollView != temp, temp.contentOffset.y < -remainHeight else { return }
                temp.contentOffset.y = -remainHeight
            }
        }
    }
    
    deinit {
        self.observers.forEach { $0.invalidate() }
        self.observers = []
    }
}
