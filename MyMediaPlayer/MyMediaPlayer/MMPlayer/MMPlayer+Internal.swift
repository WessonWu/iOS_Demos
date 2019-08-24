//
//  MMPlayer+Internal.swift
//  MyMediaPlayer
//
//  Created by wuweixin on 2019/8/24.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

// MARK: - 后台在线加载音频支持(支持后台处理mediaServicesWereResetNotification)
extension MMPlayer {
    /// 根据需要启用backgroundTask
    /// 条件：（防止滥用）
    /// 1、播放中
    /// 2、处于后台
    func beginBackgroundTaskIfNeeded() {
        guard UIApplication.shared.applicationState != .active && self.isPlaying else {
            endBackgroundTaskIfNeeded()
            return
        }
        
        if self.backgroundTaskIdentifier == nil || self.backgroundTaskIdentifier == .invalid {
            self.backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: { [weak self] in
                self?.endBackgroundTaskIfNeeded()
            })
        }
    }
    
    /// 结束backgroundTask
    func endBackgroundTaskIfNeeded() {
        guard let backgroundTaskIdentifier = self.backgroundTaskIdentifier else {
            return
        }
        defer {
            self.backgroundTaskIdentifier = nil
        }
        if backgroundTaskIdentifier != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
        }
    }
}

// Time Observer Management
extension MMPlayer {
    func addPeriodicTimerObserver(for player: AVPlayer) {
        let timescale = CMTimeScale(NSEC_PER_SEC)
        let interval = CMTime(seconds: 1, preferredTimescale: timescale)
        self.periodicTimerObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main, using: { [weak self] (time) in
            guard let strongSelf = self,
                let avPlayerItem = strongSelf.avPlayerItem,
                strongSelf.avPlayer?.currentItem == avPlayerItem else {
                    return
            }
            strongSelf.delegate?.player(strongSelf,
                                        currentTimeDidChanged: time,
                                        duration: avPlayerItem.duration)
        })
    }
    
    func removePeriodicTimerObserver(forPlayer player: AVPlayer) {
        if let timeObserverToken = self.periodicTimerObserverToken {
            player.removeTimeObserver(timeObserverToken)
            self.periodicTimerObserverToken = nil
        }
    }
}

// MARK: - KVO & Notification Observers
extension MMPlayer {
    func addNotifications() {
        addNotification(name: AVAudioSession.interruptionNotification,
                        selector: #selector(audioSessionInterruption(_:)),
                        object: nil)
        addNotification(name: AVAudioSession.routeChangeNotification,
                        selector: #selector(audioSessionRouteChange(_:)),
                        object: nil)
        addNotification(name: AVAudioSession.mediaServicesWereLostNotification,
                        selector: #selector(recoverPlaybackFromError),
                        object: nil)
        addNotification(name: Notification.Name(rawValue: kCMTimebaseNotification_EffectiveRateChanged as String),
                        selector: #selector(effectiveRateChanged(_:)),
                        object: nil)
        addNotification(name: UIApplication.didEnterBackgroundNotification,
                        selector: #selector(applicationLifeCycleHandler(_:)),
                        object: nil)
        addNotification(name: UIApplication.didBecomeActiveNotification,
                        selector: #selector(applicationLifeCycleHandler(_:)),
                        object: nil)
    }
    
    func removeNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func addObserversForAVPlayerItem(_ playerItem: AVPlayerItem) {
        addKVOObserver(for: playerItem, with: #keyPath(AVPlayerItem.status))
        addKVOObserver(for: playerItem, with: #keyPath(AVPlayerItem.isPlaybackBufferEmpty))
        addKVOObserver(for: playerItem, with: #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp))
        addKVOObserver(for: playerItem, with: #keyPath(AVPlayerItem.loadedTimeRanges))
        
        addNotification(name: .AVPlayerItemDidPlayToEndTime,
                        selector: #selector(playerItemDidPlayToEndTime(_:)),
                        object: playerItem)
        addNotification(name: .AVPlayerItemFailedToPlayToEndTime,
                        selector: #selector(playerItemOthersNotifier(_:)),
                        object: playerItem)
        addNotification(name: .AVPlayerItemPlaybackStalled,
                        selector: #selector(playerItemOthersNotifier(_:)),
                        object: playerItem)
    }
    
    func removeObserversForAVPlayerItem(_ playerItem: AVPlayerItem) {
        removeKVOObserver(for: playerItem, with: #keyPath(AVPlayerItem.status))
        removeKVOObserver(for: playerItem, with: #keyPath(AVPlayerItem.isPlaybackBufferEmpty))
        removeKVOObserver(for: playerItem, with: #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp))
        removeKVOObserver(for: playerItem, with: #keyPath(AVPlayerItem.loadedTimeRanges))
        
        removeNotification(name: .AVPlayerItemDidPlayToEndTime,
                           object: playerItem)
        removeNotification(name: .AVPlayerItemFailedToPlayToEndTime,
                           object: playerItem)
        removeNotification(name: .AVPlayerItemPlaybackStalled,
                           object: playerItem)
    }
    
    /// 收到远程控制命令的回调
    @objc
    func didReceiveRemoteCommandEvent(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        guard self.shouldReceiveRemoteEvents else { return .commandFailed }
        if let status = delegate?.player(self, handleRemoteCommandEvent: event) {
            return status
        }
        return handleRemoteCommandEvent(event)
    }
    
    
    /// 音频中断通知
    @objc
    func audioSessionInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let rawValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: rawValue) else { return }
        let options: AVAudioSession.InterruptionOptions?
        if let rawValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
            options = AVAudioSession.InterruptionOptions(rawValue: rawValue)
        } else {
            options = nil
        }
        let context: AudioSessionInterruptionContext
        if #available(iOS 10.3, *) {
            let wasSuspened = userInfo[AVAudioSessionInterruptionWasSuspendedKey] as? Bool ?? false
            context = AudioSessionInterruptionContext(type: type, options: options, wasSuspened: wasSuspened)
        } else {
            context = AudioSessionInterruptionContext(type: type, options: options)
        }
        DispatchQueue.runOnMainThreadSafely {
            self.delegate?.player(self, didReceiveAudioSessionInterruption: context)
            self.didReceiveAudioSessionInterruption(context)
        }
    }
    
    /// 音频输入输出改变通知
    @objc
    func audioSessionRouteChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let rawValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
            let reason = AVAudioSession.RouteChangeReason(rawValue: rawValue) else {
                return
        }
        let previousRouteDescription: AVAudioSessionRouteDescription?
        if let previousRoute = userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription {
            previousRouteDescription = previousRoute
        } else {
            previousRouteDescription = nil
        }
        let context = AudioSessionRouteChangeContext(reason: reason, previousRouteDescription: previousRouteDescription)
        DispatchQueue.runOnMainThreadSafely {
            self.delegate?.player(self, didReceiveAudioSessionRouteChange: context)
            self.didReceiveAudioSessionRouteChange(context)
        }
    }
    
    /// 监听AVPlayerItem的其他通知
    /// 1. 播放失败
    /// 2. 卡顿问题
    @objc
    func playerItemOthersNotifier(_ notification: Notification) {
        guard let playerItem = notification.object as? AVPlayerItem,
            playerItem.isEqual(self.avPlayerItem) else { return }
        
        switch notification.name {
        case .AVPlayerItemFailedToPlayToEndTime:
            tryToRetrieveDataWhenPlaying()
        case .AVPlayerItemPlaybackStalled:
            tryToRetrieveDataWhenPlaying()
        default: break
        }
    }
    
    /// 该通知用于监听真正处于播放或等待状态
    /// CMTimebaseGetRate(AVPlayerItem.timebase) == 1: AVPlayer真正处于播放状态
    /// CMTimebaseGetRate(AVPlayerItem.timebase) == 0: AVPlayer并未播放(处于Waiting/Paused状态)
    @objc
    func effectiveRateChanged(_ notification: Notification) {
        DispatchQueue.runOnMainThreadSafely {
            self.detectWaitingForPlayback()
        }
    }
    
    @objc
    func playerItemDidPlayToEndTime(_ notification: Notification) {
        guard let playerItem = notification.object as? AVPlayerItem,
            playerItem.isEqual(self.avPlayerItem) else {
                return
        }
        
        self.pause()
        DispatchQueue.runOnMainThreadSafely {
            self.delegate?.playerDidPlayToEndTime(self)
        }
        
        didPlayToEndTime(playerItem)
    }
    
    /// UIApplication生命周期事件处理
    @objc
    func applicationLifeCycleHandler(_ notification: Notification) {
        switch notification.name {
        case UIApplication.didEnterBackgroundNotification:
            beginBackgroundTaskIfNeeded()
        case UIApplication.didBecomeActiveNotification:
            endBackgroundTaskIfNeeded()
        default:
            break
        }
    }
}

extension MMPlayer {
    @inline(__always) func addKVOObserver(for playerItem: AVPlayerItem, with keyPath: String) {
        playerItem.addObserver(self, forKeyPath: keyPath, options: [.old, .new], context: &avPlayerItemObserverContext)
    }
    
    @inline(__always) func removeKVOObserver(for playerItem: AVPlayerItem, with keyPath: String) {
        playerItem.removeObserver(self, forKeyPath: keyPath, context: &avPlayerItemObserverContext)
    }
    
    @inline(__always) func addNotification(name: Notification.Name, selector: Selector, object: Any?) {
        NotificationCenter.default.addObserver(self, selector: selector, name: name, object: object)
    }
    
    @inline(__always) func removeNotification(name: Notification.Name, object: Any?) {
        NotificationCenter.default.removeObserver(self, name: name, object: object)
    }
}
