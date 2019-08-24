//
//  简单的高度封装的媒体播放器
//

import AVFoundation
import MediaPlayer

// MMPlayer: My Media Player

open class MMPlayer: NSObject {
    /// 播放器代理
    open weak var delegate: MMPlayerDelegate?
    
    // MARK: - 播放状态
    /// 播放器状态
    open private(set) var status: MMPlayerStatus = .unknown {
        didSet {
            DispatchQueue.runOnMainThreadSafely {
                self.delegate?.player(self, playerStatusDidSet: self.status, oldStatus: oldValue)
            }
        }
    }
    /// 播放状态
    open private(set) var playbackState: MMPlaybackState = .stopped {
        didSet {
            DispatchQueue.runOnMainThreadSafely {
                self.delegate?.player(self, playbackStateDidSet: self.playbackState, oldState: oldValue)
                if self.playbackState == .playing {
                    self.beginBackgroundTaskIfNeeded()
                } else {
                    self.endBackgroundTaskIfNeeded()
                }
            }
        }
    }
    /// 是否正在播放
    open var isPlaying: Bool {
        return playbackState == .playing
    }
    
    // MARK: 内部播放播放器
    /// 用于播放的AVPlayer
    open private(set) var avPlayer: AVPlayer? {
        didSet {
            if let player = oldValue {
                removePeriodicTimerObserver(forPlayer: player)
            }
            if let player = self.avPlayer {
                addPeriodicTimerObserver(for: player)
            }
        }
    }
    /// 用于播放的AVPlayerItem
    open private(set) var avPlayerItem: AVPlayerItem? {
        didSet {
            if let playerItem = oldValue {
                removeObserversForAVPlayerItem(playerItem)
            }
            if let playerItem = self.avPlayerItem {
                addObserversForAVPlayerItem(playerItem)
            }
        }
    }
    /// 用于播放的AVURLAsset
    open private(set) var avURLAsset: AVURLAsset?
    
    /// 播放速率
    open var playbackRate: Float = 1 {
        didSet {
            if let player = self.avPlayer, player.rate != self.playbackRate && self.isPlaying {
                setRate(self.playbackRate)
            }
        }
    }
    
    /// 播放器发生的错误
    open private(set) var error: Error?
    
    open var keysOfAVURLAssetLoadValuesAsynchronously: [String] {
        return ["playable"]
    }
    
    /// 当前的播放源
    open private(set) var mediaItem: MMItemType? {
        didSet {
            DispatchQueue.runOnMainThreadSafely {
                self.delegate?.player(self, mediaItemDidSet: self.mediaItem, oldItem: oldValue)
            }
        }
    }
    
    
    // MRAK: - Remote Control Management
    /// 是否可以接受远程事件 (控制是否响应控制中心的命令)
    open var shouldReceiveRemoteEvents: Bool = true {
        didSet {
            shouldReceiveRemoteEventsAdjustment()
        }
    }
    /// 是否该显示nowPlayingInfo
    open var shouldDisplayNowPlayingInfo: Bool = true
    /// 控制中心显示的信息
    open private(set) var nowPlayingInfo: [String: Any] = [:]
    
    // MARK: - 其他
    /// 是否正在等待播放 (根据需要显示加载中样式)
    @objc dynamic open private(set) var isWaitingForPlayback: Bool = false
    /// 媒体是否已经加载完成
    @objc dynamic open private(set) var isMediaLoadCompleted: Bool = false
    
    public override init() {
        super.init()
        addNotifications()
    }
    
    // MARK: - 播放核心方法
    open func play() {
        self.shouldResumeFromAudioSessionInterruption = false
        guard avURLAsset != nil && tryToRetrieveData() else {
            return setRate(0)
        }
        initAVPlayerIfNeeded()
        reloadAVPlayerItemIfNeeded()
        resumeLoading()
        setRate(playbackRate)
        self.playbackState = .playing
        updateNowPlayingInfoCenter()
    }

    open func pause() {
        self.shouldResumeFromAudioSessionInterruption = false
        guard avURLAsset != nil && playbackState == .playing else {
            setRate(0)
            return
        }
        setRate(0)
        self.playbackState = .paused
        updateNowPlayingInfoCenter()
        detectWaitingForPlayback()
    }
    
    open func stop() {
        self.shouldResumeFromAudioSessionInterruption = false
        self.avURLAsset?.cancelLoading()
        guard avURLAsset != nil else {
            return setRate(0)
        }
        setRate(0)
        avPlayer?.replaceCurrentItem(with: nil)
        self.playbackState = .stopped
        detectWaitingForPlayback()
    }
    
    open func setRate(_ rate: Float, force: Bool = false) {
        guard let player = self.avPlayer else { return }
        if player.rate != rate {
            player.rate = rate
        }
    }
    
    /// 替换当前正在播放的媒体源
    ///
    /// - Parameter mediaItem: 媒体源
    /// - Returns: 是否成功设置
    @discardableResult
    open func replaceCurrentItem(with mediaItem: MMItemType?) -> Bool {
        // reset the player to initial state for preparing for playback next item.
        reset()
        
        // set the media item and check if exists.
        self.mediaItem = mediaItem
        guard let item = self.mediaItem else {
            return false
        }
        
        // check url is not nil.
        guard let url = item.assetURL else {
            let localizedDescription = NSLocalizedString("URL cannot be nil.",
                                                         comment: "URL cannot be nil description")
            let localizedFailureReason = NSLocalizedString("URL was nil",
                                                           comment: "URL cannot be nil failure reason")
            let userInfo: [String: Any] = [NSLocalizedDescriptionKey: localizedDescription,
                                           NSLocalizedFailureReasonErrorKey: localizedFailureReason]
            failedToPlayWithError(URLError(.badURL, userInfo: userInfo))
            return false
        }
        
        
        // Create and load AVURLAsset asynchronously.
        self.status = .unknown
        let keys = keysOfAVURLAssetLoadValuesAsynchronously
        let urlAsset = AVURLAsset(url: url)
        self.avURLAsset = urlAsset
        urlAsset.loadValuesAsynchronously(forKeys: keys) { [weak self] in
            DispatchQueue.runOnMainThreadSafely {
                self?.prepareToPlayAsset(urlAsset, withKeys: keys)
            }
        }
        
        // setup now playing info center
        setupNowPlayingInfoCenter(with: item)
        // Adjusts remote control center button state.
        shouldReceiveRemoteEventsAdjustment()
        
        return true
    }
    
    /// 恢复AVPlayerItem缓存数据
    /// 当AVPlayer的playerItem不为nil时才会加载数据
    open func resumeLoading() {
        guard let player = self.avPlayer,
            let playerItem = self.avPlayerItem,
            player.currentItem == nil else {
            return
        }
        player.replaceCurrentItem(with: playerItem)
    }
    
    // MARK: - Seek
    open func seekSafely(to time: CMTime, tolerance: CMTime = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), completionHandler: ((Bool) -> Void)? = nil) {
        guard let playerItem = self.avPlayerItem, time.isValid && !time.isIndefinite else {
            return
        }
        
        // 预防：
        // Fatal Exception: NSInvalidArgumentException
        // AVPlayerItem cannot service a seek request with a completion handler until its status is AVPlayerItemStatusReadyToPlay.
        guard playerItem.status == .readyToPlay else {
            self.pendingSeekTime = time
            return
        }
        if let completion = completionHandler {
            playerItem.seek(to: time, toleranceBefore: tolerance, toleranceAfter: tolerance, completionHandler: completion)
        } else {
            playerItem.seek(to: time, toleranceBefore: tolerance, toleranceAfter: tolerance)
        }
    }
    
    // MARK: - 播放错误
    open func failedToPlayWithError(_ error: Error?) {
        self.error = error
        self.status = .error
    }
    
    // MARK: - 相关状态的处理
    /// 尝试加载数据 (一般判断网络环境)
    @discardableResult
    open func tryToRetrieveData() -> Bool {
        guard self.avURLAsset != nil else { return false }
        if isMediaLoadCompleted {
            return true
        }
        detectWaitingForPlayback()
        return true
    }
    
    // MARK: - 控制中心
    open func setupNowPlayingInfoCenter(with mediaItem: MMItemType) {
        guard shouldDisplayNowPlayingInfo else {
            return
        }
        let rate = self.avPlayer?.rate ?? 0
        var nowPlayingInfo = self.nowPlayingInfo
        nowPlayingInfo[MPMediaItemPropertyArtist] = mediaItem.artist
        nowPlayingInfo[MPMediaItemPropertyTitle] = mediaItem.title
        // artwork
        if let artwork = mediaItem.artwork {
            switch artwork {
            case .none:
                break
            case .url(let url):
                // Retrive artwork image from delegate
                delegate?.player(self, retriveArtworkImageWithURL: url, completion: { [weak self] (image) in
                    guard let strongSelf = self,
                        strongSelf.mediaItem?.artwork == mediaItem.artwork,
                        let resultImage = image else {
                        return
                    }
                    DispatchQueue.runOnMainThreadSafely {
                        var nowPlayingInfo = strongSelf.nowPlayingInfo
                        nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: resultImage)
                        strongSelf.nowPlayingInfo = nowPlayingInfo
                        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
                    }
                })
                break
            case .image(let image):
                nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: image)
            }
        }
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = NSNumber(value: mediaItem.duration)
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = rate
        self.nowPlayingInfo = nowPlayingInfo
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    open func updateNowPlayingInfoCenter(withElapsedTime elapsed: TimeInterval? = nil) {
        guard shouldDisplayNowPlayingInfo else {
            return
        }
        var nowPlayingInfo = self.nowPlayingInfo
        if let elapsed = elapsed {
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSNumber(value: elapsed)
        }
        if let rate = self.avPlayer?.rate {
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = rate
        }
        self.nowPlayingInfo = nowPlayingInfo
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    open func cleanNowPlayingInfo(_ center: MPNowPlayingInfoCenter? = nil) {
        self.nowPlayingInfo = [:]
        center?.nowPlayingInfo = nil
    }
    
    /// MARK: - 远程命令    
    open var supportedRemoteCommands: [MPRemoteCommand] {
        let center = MPRemoteCommandCenter.shared()
        var commands = [center.playCommand,
                        center.pauseCommand,
                        center.togglePlayPauseCommand]
        if #available(iOS 10.0, *) {
            commands.append(center.changePlaybackPositionCommand)
        }
        return commands
    }
    
    open func setRemoteCommandEventsEnabled(_ enabled: Bool) {
        let center = MPRemoteCommandCenter.shared()
        let supported = self.supportedRemoteCommands
        center.commonCommands.forEach {
            if supported.contains($0) {
                $0.isEnabled = enabled
            } else {
                $0.isEnabled = false
            }
        }
    }
    
    open func addRemoteCommandEvents() {
        removeRemoteCommandEvents()
        setRemoteCommandEventsEnabled(true)
        
        supportedRemoteCommands.forEach {
            $0.addTarget(self, action: #selector(didReceiveRemoteCommandEvent(_:)))
        }
    }
    
    open func removeRemoteCommandEvents() {
        supportedRemoteCommands.forEach {
            $0.removeTarget(self)
        }
    }
    
    /// 处理远程控制命令
    /// 注意：只有delegate的handleRemoteCommandEvent方法
    /// 返回nil时，才会调用该方法
    open func handleRemoteCommandEvent(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        let center = MPRemoteCommandCenter.shared()
        switch event.command {
        case center.playCommand:
            play()
        case center.pauseCommand:
            pause()
        case center.togglePlayPauseCommand:
            if isPlaying {
                pause()
            } else {
                play()
            }
        default:
            return .commandFailed
        }
        return .success
    }
    
    open func didReceiveAudioSessionInterruption(_ context: AudioSessionInterruptionContext) {
        switch context.type {
        case .began:
            let isPlayingBefore = self.isPlaying
            self.pause() // 暂停播放
            self.shouldResumeFromAudioSessionInterruption = isPlayingBefore
        case .ended:
            guard let options = context.options,
                options.contains(.shouldResume)
                    && self.shouldReceiveRemoteEvents
                    && self.shouldResumeFromAudioSessionInterruption else {
                        return
            }
            self.play()
        @unknown default:
            break
        }
    }
    
    /// 音频输入/输出改变
    ///
    /// - Parameter context: 音频输入/输出上下文
    open func didReceiveAudioSessionRouteChange(_ context: AudioSessionRouteChangeContext) {
        switch context.reason {
        case .oldDeviceUnavailable:
            guard let previousOutput = context.previousRouteDescription?.outputs.first else { return }
            switch previousOutput.portType {
            case .headphones,
                 .bluetoothLE,
                 .bluetoothHFP,
                 .bluetoothA2DP:
                self.pause()
            default: break
            }
        default: break
        }
    }
    
    /// AVPlayerItem播放完成
    ///
    /// - Parameter playerItem: 播放完成的AVPlayerItem
    open func didPlayToEndTime(_ playerItem: AVPlayerItem) {}
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &avPlayerItemObserverContext,
            let key = keyPath,
            let playerItem = self.avPlayerItem else {
                return super.observeValue(forKeyPath: keyPath,
                                          of: object,
                                          change: change,
                                          context: context)
        }
        
        switch key {
        case #keyPath(AVPlayerItem.status):
            guard let statusNumber = change?[.newKey] as? NSNumber else {
                return
            }
            let status: AVPlayerItem.Status = AVPlayerItem.Status(rawValue: statusNumber.intValue) ?? .unknown
            switch status {
            case .unknown:
                break
            case .readyToPlay:
                self.status = .readyToPlay
                if let seekTime = self.pendingSeekTime {
                    self.pendingSeekTime = nil
                    self.seekSafely(to: seekTime)
                }
            case .failed:
                // 加载出错
                failedToPlayWithError(playerItem.error)
            @unknown default:
                #if DEBUG
                print("Unknown AVPlayerItem's status")
                #endif
            }
        case #keyPath(AVPlayerItem.isPlaybackBufferEmpty):
            // 当isPlaybackBufferEmpty == true: 检查是否可以加载数据，以便提示网络相关的状态
            if playerItem.isPlaybackBufferEmpty {
                tryToRetrieveDataWhenPlaying()
            }
        case #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp):
            // 当isPlaybackLikelyToKeepUp == true: 恢复播放
            // 当isPlaybackLikelyToKeepUp == false: 检查是否可以加载数据，以便提示网络相关的状态
            if playerItem.isPlaybackLikelyToKeepUp {
                resumeIfNeeded()
            } else {
                tryToRetrieveDataWhenPlaying()
            }
        case #keyPath(AVPlayerItem.loadedTimeRanges):
            self.isMediaLoadCompleted = playerItem.isLoadCompleted
            
            DispatchQueue.runOnMainThreadSafely {
                if let delegate = self.delegate {
                    delegate.player(self, loadedTimeRangesDidChanged: playerItem.loadedTimeRanges.map { $0.timeRangeValue })
                }
            }
        default: break
        }
    }
    
    /// 重置音频播放器
    public final func reset() {
        DispatchQueue.checkOnMainThread()
        defer {
            self.delegate?.playerWasReset(self)
        }
        stop()
        cleanNowPlayingInfo()
        self.pendingSeekTime = nil
        self.mediaItem = nil
        self.avURLAsset = nil
        self.avPlayerItem = nil
        self.isMediaLoadCompleted = false
        self.isWaitingForPlayback = false
        self.status = .unknown
    }
    
    deinit {
        removeNotifications()
    }
    
    // 是否应该从音频中断中恢复播放 (修复5s 9.0截屏使得在暂停中的音频开始播放)
    var shouldResumeFromAudioSessionInterruption: Bool = false
    /// 保存当前的进度（用于从错误中恢复播放）
    var pendingSeekTime: CMTime?
    /// The backgroundTaskIdentifier for media buffering in background
    var backgroundTaskIdentifier: UIBackgroundTaskIdentifier?
    // MARK: - 监听相关
    var periodicTimerObserverToken: Any?
    var avPlayerItemObserverContext: Void = ()
    
    // MARK: - 准备工作
    // 惰性初始化AVPlayer
    private func initAVPlayerIfNeeded() {
        let session = AVAudioSession.sharedInstance()
        defer {
            do {
                try session.setActive(true)
            } catch {
                #if DEBUG
                print(error)
                #endif
            }
        }
        guard self.avPlayer == nil else {
            return
        }
        
        let player = AVPlayer()
        self.avPlayer = player
        
        player.actionAtItemEnd = .pause
        if #available(iOS 10.0, *) {
            player.automaticallyWaitsToMinimizeStalling = false
        }
        
        do {
            if #available(iOS 10.0, *) {
                try session.setCategory(.playback, mode: .default, options: [.defaultToSpeaker, .allowBluetooth, .allowBluetoothA2DP])
            } else {
                try session.setCategory(.playback, options: [.defaultToSpeaker, .allowBluetooth])
                try session.setMode(.default)
            }
        } catch {
            #if DEBUG
            print(error)
            #endif
        }
    }
    
    /// 检查是否有必要重新加载AVPlayerItem
    private func reloadAVPlayerItemIfNeeded() {
        guard let mediaItem = self.mediaItem else {
            return
        }
        let playerItem = self.avPlayerItem
        if self.status != .unknown && (playerItem == nil || playerItem?.status == .failed) {
            self.avPlayer?.replaceCurrentItem(with: nil)
            self.replaceCurrentItem(with: mediaItem)
        }
    }
    
    private func prepareToPlayAsset(_ urlAsset: AVURLAsset, withKeys keys: [String]) {
        // 保证已经切换掉的AVURLAsset不会执行以下逻辑
        guard urlAsset == self.avURLAsset else {
            return
        }
        var outError: NSError?
        let keyOfFailToLoad = keys.first { (key) -> Bool in
            return urlAsset.statusOfValue(forKey: key, error: &outError) == .failed
        }
        guard keyOfFailToLoad == nil else {
            failedToPlayWithError(outError)
            return
        }
        
        guard urlAsset.isPlayable else {
            let localizedDescription = NSLocalizedString("Item cannot be played",
                                                         comment: "Item cannot be played description")
            let localizedFailureReason = NSLocalizedString("The assets tracks were loaded, but could not be made playable.",
                                                           comment: "Item cannot be played failure reason")
            let userInfo = [NSLocalizedDescriptionKey: localizedDescription,
                            NSLocalizedFailureReasonErrorKey: localizedFailureReason]
            failedToPlayWithError(AVError(.unknown, userInfo: userInfo))
            return
        }
        let playerItem = AVPlayerItem(asset: urlAsset)
        self.avPlayerItem = playerItem
        //        self.avPlayer?.replaceCurrentItem(with: playerItem)
    }
    
    /// 处理偶尔当AVPlayerItem的isPlaybackLikelyToKeepUp为true的时候无法自动进行播放
    func resumeIfNeeded() {
        if let playerItem = self.avPlayer?.currentItem,
            playerItem.status != .failed && self.isPlaying {
            setRate(playbackRate)
        }
    }
    
    /// 用于在播放中，在需要的时候（结合卡顿、isPlaybackLikelyToKeepUp和isPlaybackBufferEmpty和isPlaybackBufferFulll状态）询问网络环境
    func tryToRetrieveDataWhenPlaying() {
        guard isPlaying else { return }
        tryToRetrieveData()
    }
    
    /// 检测是否等待播放
    func detectWaitingForPlayback() {
        guard self.isPlaying else {
            self.isWaitingForPlayback = false
            return
        }
        
        if let playerItem = self.avPlayerItem,
            let timebase = playerItem.timebase {
            if CMTimebaseGetRate(timebase) == 0 {
                // wait for playback
                self.isWaitingForPlayback = !playerItem.isPlaybackLikelyToKeepUp
            } else {
                self.isWaitingForPlayback = false
            }
        } else {
            self.isWaitingForPlayback = true
        }
    }
    
    /// 从出错的情况下恢复播放 (一般处理收到mediaServicesWereResetNotification)
    /// 调试方法：系统Settings -> Development -> Reset Media Services
    /// 相关介绍：https://developer.apple.com/library/archive/qa/qa1749/_index.html
    @objc
    func recoverPlaybackFromError() {
        guard let player = self.avPlayer, self.avURLAsset != nil else {
            return
        }
        self.pendingSeekTime = self.avPlayerItem?.currentTime()
        self.avPlayer = nil
        self.avPlayerItem = nil
        player.replaceCurrentItem(with: nil)
        if isPlaying {
            play()
        } else {
            pause()
        }
    }
    
    private func shouldReceiveRemoteEventsAdjustment() {
        setRemoteCommandEventsEnabled(self.shouldReceiveRemoteEvents)
    }
}
