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
    
    
    /// 替换播放队列
    ///
    /// - Parameters:
    ///   - mediaItems: 播放队列
    ///   - index: 想要播放的队列中的index
    ///   - isAutoPlay: 是否自动播放
    ///   - forceToReplay: 当要播放的item与之前的item一致时，是否重新播放
    open func replaceMediaItems(_ mediaItems: [MMItemType], index: Int, isAutoPlay: Bool = false, forceToReplay: Bool = false) {
        self.mediaItems = mediaItems
        play(at: index, isAutoPlay: isAutoPlay, forceToReplay: forceToReplay)
    }
    
    /// 前一首
    open func previous() {
        let count = mediaItems.count
        guard count > 0 else { return }
        
        let index = (currentIndex - 1 + count) % count
        play(at: index, isAutoPlay: true, forceToReplay: true)
    }
    
    /// 下一首
    open func next() {
        let count = mediaItems.count
        guard count > 0 else { return }
        
        let index = (currentIndex + 1) % count
        play(at: index, isAutoPlay: true, forceToReplay: true)
    }
    
    /// 随机播放
    open func random() {
        let count = mediaItems.count
        guard count > 0 else { return }
        
        let index = Int(arc4random()) % count
        play(at: index, isAutoPlay: true, forceToReplay: true)
    }
    
    /// 重播
    open func replay() {
        seekSafely(to: .zero, completionHandler: nil)
        play()
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
    
    public final func mediaItem(at index: Int) -> MMItemType? {
        guard index >= 0 && index < mediaItems.count else {
            return nil
        }
        
        return mediaItems[index]
    }
    
    private func play(at index: Int, isAutoPlay: Bool = true, forceToReplay: Bool = false) {
        guard let mediaItem = mediaItem(at: index) else {
            return stop()
        }
        
        let tryToPlayTheSameMediaItem = self.mediaItem?.uniqueID == mediaItem.uniqueID
            && self.avURLAsset?.url == mediaItem.assetURL
            && self.avPlayerItem?.asset == self.avURLAsset
        self.currentIndex = index
        if tryToPlayTheSameMediaItem {
            if forceToReplay {
                seekSafely(to: .zero)
            }
            if isAutoPlay {
                play()
            }
        } else {
            if self.replaceCurrentItem(with: mediaItem) && isAutoPlay {
                play()
            }
        }
    }
}
