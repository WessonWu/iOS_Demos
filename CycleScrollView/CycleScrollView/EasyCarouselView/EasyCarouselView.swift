//
//  EasyCarouselView
//
//  Created by wuweixin on 2019/6/11.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit

public class EasyCarouselView: UIView {
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: EasyCarouselFlowLayout())
    private var autoScrollTimer: Timer?
    
    public var isAutoScroll: Bool = true
    /// 自动滚动时间间隔
    public var timeIntervalForAutoScroll: TimeInterval = 3
    
    public weak var dataSource: EasyCarouselDataSource? {
        didSet {
            reloadData()
        }
    }
    
    public weak var delegate: EasyCarouselDelegate?
    
    public private(set) var numberOfItems: Int = 0
    public var currentItem: Int? {
        let visibleRect = collectionView.bounds
        return indexForPoint(CGPoint(x: visibleRect.midX, y: visibleRect.midY))
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        collectionView.backgroundColor = nil
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = .fast
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.bounces = true
        
        setupAutoLayout()
    }
    
    public func setupAutoLayout() {
        collectionView.frame = self.bounds
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(collectionView)
    }
    
    public func reloadData() {
        self.collectionView.reloadData()
        fetchNumberOfItems()
        scrollCurrentItemToCenter()
    }
    
    public final func scrollToItem(at index: Int, animated: Bool) {
        let listView = self.collectionView
        guard listView.numberOfSections > 0
            && index < listView.numberOfItems(inSection: 0) else {
            return
        }
        let indexPath = IndexPath(item: index, section: listView.numberOfSections / 2)
        listView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
    }
    
    public func setupCollectionView(_ setter: (UICollectionView) -> Void) {
        setter(collectionView)
    }
    
    public func indexForPoint(_ point: CGPoint) -> Int? {
        return collectionView.indexPathForItem(at: point)?.item
    }
    
    public override func didMoveToWindow() {
        super.didMoveToWindow()
        let isAttachedToWindow = self.window != nil
        if isAttachedToWindow {
            DispatchQueue.main.async {
                self.scrollCurrentItemToCenter()
            }
        }
        if isAutoScroll {
            if isAttachedToWindow {
                startAutoScroller()
            } else {
                stopAutoScroller()
            }
        }
    }
    
    private func fetchNumberOfItems() {
        self.numberOfItems = dataSource?.numberOfItems(in: self) ?? 0
    }
    
    private func scrollCurrentItemToCenter() {
        guard let index = self.currentItem else {
            return
        }
        scrollToItem(at: index, animated: false)
    }
}

/// 重用支持
extension EasyCarouselView {
    public func register(_ cellClass: AnyClass?, forCellWithReuseIdentifier reuseIdentifier: String) {
        collectionView.register(cellClass, forCellWithReuseIdentifier: reuseIdentifier)
    }
    public func dequeueReusableCell(withReuseIdentifier reuseIdentifier: String, for indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    }
}

/// 自动滚动支持
extension EasyCarouselView {
    /// 开启自动滚动
    public final func startAutoScroller() {
        guard self.autoScrollTimer == nil else {
            return
        }
        let timeInterval = self.timeIntervalForAutoScroll
        let timer = Timer(timeInterval: timeInterval,
                          target: self,
                          selector: #selector(autoScrollTick),
                          userInfo: nil,
                          repeats: true)
        self.autoScrollTimer = timer
        timer.fireDate = Date(timeIntervalSinceNow: timeInterval)
        RunLoop.main.add(timer, forMode: .common)
    }
    
    /// 停止自动滚动 (必须调用，否则内存泄漏)
    public final func stopAutoScroller() {
        self.autoScrollTimer?.invalidate()
        self.autoScrollTimer = nil
    }
    
    private func pauseAutoScroller() {
        self.autoScrollTimer?.fireDate = .distantFuture
    }
    
    private func resumeAutoScroller() {
        guard let timer = self.autoScrollTimer else {
            return
        }
        timer.fireDate = Date(timeIntervalSinceNow: timer.timeInterval)
    }
    
    @objc
    private func autoScrollTick() {
        let listView = self.collectionView
        let visibleRect = listView.bounds
        let center = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        guard !listView.isTracking, let indexPath = collectionView.indexPathForItem(at: center) else {
            return
        }
        
        let numberOfSections = listView.numberOfSections
        let numberOfItems = listView.numberOfItems(inSection: indexPath.section)
        let section = (indexPath.section + (indexPath.item + 1) / numberOfItems) % numberOfSections
        let item = (indexPath.item + 1) % numberOfItems
        
        listView.scrollToItem(at: IndexPath(item: item, section: section),
                              at: .centeredHorizontally,
                              animated: true)
    }
}


extension EasyCarouselView: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        fetchNumberOfItems()
        return numberOfItems > 1 ? 20 : 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItems
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let ds = self.dataSource else {
            fatalError("CarouselView's dataSource can't be nil!")
        }
        return ds.carouselView(self, cellForItemAt: indexPath)
    }
}

extension EasyCarouselView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.carouselView(self, didSelectItemAt: indexPath)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return .zero
        }
        if section > 0 {
            return UIEdgeInsets(top: 0, left: flowLayout.minimumLineSpacing, bottom: 0, right: 0)
        }
        return .zero
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollCurrentItemToCenter()
        resumeAutoScroller()
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollCurrentItemToCenter()
        resumeAutoScroller()
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate {
            pauseAutoScroller()
        }
    }
}
