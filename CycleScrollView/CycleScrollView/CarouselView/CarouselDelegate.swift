//
//  CarouselDelegate.swift
//  CycleScrollView
//
//  Created by wuweixin on 2019/6/11.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit

public protocol CarouselDataSource: AnyObject {
    func numberOfItems(in carouselView: CarouselView) -> Int
    func carouselView(_ carouselView: CarouselView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
}

public protocol CarouselDelegate: AnyObject {
    func carouselView(_ carouselView: CarouselView, didSelectItemAt indexPath: IndexPath)
}

extension CarouselDelegate {
    func carouselView(_ carouselView: CarouselView, didSelectItemAt indexPath: IndexPath) {}
}

