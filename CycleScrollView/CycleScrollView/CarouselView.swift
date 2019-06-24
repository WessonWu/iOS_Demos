//
//  MyCarouselView.swift
//  CycleScrollView
//
//  Created by wuweixin on 2019/6/24.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit


final class CarouselView: EasyCarouselView {
    
    let pageControl: UIPageControl = UIPageControl()
    
    override func setupAutoLayout() {
        super.setupAutoLayout()
        pageControl.hidesForSinglePage = true
        self.addSubview(pageControl)
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        let constraintOfCenterX = pageControl.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        let constraintOfBottom = pageControl.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20)
        
        NSLayoutConstraint.activate([constraintOfCenterX, constraintOfBottom])
    }
    
    
    override func reloadData() {
        super.reloadData()
        
        pageControl.numberOfPages = numberOfItems
        pageControl.currentPage = currentItem ?? 0
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let index = self.currentItem {
            pageControl.currentPage = index
        }
    }
}
