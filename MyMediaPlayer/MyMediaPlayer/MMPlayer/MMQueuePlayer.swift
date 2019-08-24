//
//  MediaQueuePlayer.swift
//  MediaPlayer
//
//  Created by wuweixin on 2019/7/8.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import AVFoundation


open class MMQueuePlayer: MMPlayer {
    open private(set) var mediaItems: [MMItemType] = []
    open private(set) var currentIndex: Int = 0
    
    var queuePlayerDelegate: MMQueuePlayerDelegate? {
        return self.delegate as? MMQueuePlayerDelegate
    }
    
    /// 播放模式
    open var playMode: MMPlayMode = .listCycle {
        didSet {
            DispatchQueue.runOnMainThreadSafely {
                self.queuePlayerDelegate?.player(self, playModeDidSet: self.playMode, oldModel: oldValue)
            }
        }
    }
    
    /// 前一首
    public func previous() {
        let count = mediaItems.count
        guard count > 0 else { return }
        
        let index = (currentIndex - 1 + count) % count
        play(at: index, force: true)
    }
    
    /// 下一首
    public func next() {
        let count = mediaItems.count
        guard count > 0 else { return }
        
        let index = (currentIndex + 1) % count
        play(at: index, force: true)
    }
    
    public func random() {
        let count = mediaItems.count
        guard count > 0 else { return }
        
        let index = Int(arc4random()) % count
        play(at: index, force: true)
    }
    
    /// 重播
    public func replay() {
        seekSafely(to: .zero, completionHandler: nil)
    }
    
    public func play(at index: Int, force: Bool) {
        guard let mediaItem = mediaItem(at: index) else {
            return stop()
        }
        
        if self.currentIndex == index
            && self.mediaItem?.uniqueID == mediaItem.uniqueID
            && self.avURLAsset != nil {
            seekSafely(to: .zero) { [weak self] (_) in
                self?.play()
            }
        } else if self.avURLAsset == nil {
            self.currentIndex = index
            self.replaceCurrentItem(with: mediaItem)
        } else {
            
        }
    }
    
    open override func didPlayToEndTime(_ playerItem: AVPlayerItem) {
        // 根据策略播放下一首
        switch self.playMode {
        case .listCycle:
            next()
        case .singleCycle:
            replay()
        case .randomPlay:
            random()
        }
    }
    
    
    public func mediaItem(at index: Int) -> MMItemType? {
        guard index >= 0 && index < mediaItems.count else {
            return nil
        }
        
        return mediaItems[index]
    }
}
