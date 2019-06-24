//
//  EasyCarouselView
//
//  Created by wuweixin on 2019/6/11.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit

public protocol EasyCarouselDataSource: AnyObject {
    func numberOfItems(in carouselView: EasyCarouselView) -> Int
    func carouselView(_ carouselView: EasyCarouselView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
}

public protocol EasyCarouselDelegate: AnyObject {
    func carouselView(_ carouselView: EasyCarouselView, didSelectItemAt indexPath: IndexPath)
}

extension EasyCarouselDelegate {
    func carouselView(_ carouselView: EasyCarouselView, didSelectItemAt indexPath: IndexPath) {}
}

