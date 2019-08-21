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
    open private(set) var status: MMPlayerStatus = .unknown
    /// 播放状态
    open private(set) var playbackState: MMPlaybackState = .stopped {
        didSet {
            DispatchQueue.runOnMainThreadSafely {
                self.delegate?.player(self, playbackStateDidChanged: self.playbackState, oldState: oldValue)
            }
        }
    }
    /// 是否正在播放
    open var isPlaying: Bool {
        return playbackState == .playing
    }
    /// 播放模式
    open var playMode: MMPlayMode = .listCycle
    /// 播放器发生的错误
    open private(set) var error: Error?
    
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
    
    
    // 是否应该从音频中断中恢复播放 (修复5s 9.0截屏使得在暂停中的音频开始播放)
    private var shouldResumeFromAudioSessionInterruption: Bool = false
    
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
    /// 是否处于Seek中 (防止在拖动进度条时受到影响)
    @objc dynamic open private(set) var isSeeking: Bool = false
    /// 媒体是否已经加载完成
    @objc dynamic open private(set) var isMediaLoadCompleted: Bool = false
    
    // MARK: - 监听相关
    private var periodicTimerObserverToken: Any?
    open private(set) var avPlayerItemObserverContext: Void = ()
    
    /// The backgroundTaskIdentifier for media buffering in background
    private var backgroundTaskIdentifier: UIBackgroundTaskIdentifier?
    
    public override init() {
        super.init()
        addNotifications()
    }
    
    // MARK: - 播放核心方法
    open func play() {
        initAVPlayerIfNeeded()
        reloadAVPlayerItemIfNeeded()
        resumeLoading()
        setRate(1)
        self.playbackState = .playing
        updateNowPlayingInfoCenter()
    }

    open func pause() {
        guard playbackState == .playing else {
            setRate(0)
            return
        }
        setRate(0)
        self.playbackState = .paused
        updateNowPlayingInfoCenter()
        detectWaitingForPlayback()
    }
    
    open func stop() {
        setRate(0)
        avPlayer?.replaceCurrentItem(with: nil)
        self.playbackState = .stopped
        detectWaitingForPlayback()
    }
    
    /// 播放/暂停
    open func togglePlay() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    func setRate(_ rate: Float, force: Bool = false) {
        guard let player = self.avPlayer, !isSeeking || force else { return }
        if player.rate != rate {
            player.rate = rate
        }
    }
    
    
    // MARK: - 准备工作
    // 惰性初始化AVPlayer
    func initAVPlayerIfNeeded() {
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
    
    
    open func replaceCurrentItem(with mediaItem: MMItemType?) {
        self.mediaItem = mediaItem
        
        guard let item = self.mediaItem else {
            return
        }
        
        guard let url = item.assetURL else {
            let localizedDescription = NSLocalizedString("URL cannot be nil.",
                                                         comment: "URL cannot be nil description")
            let localizedFailureReason = NSLocalizedString("URL was nil",
                                                           comment: "URL cannot be nil failure reason")
            let userInfo: [String: Any] = [NSLocalizedDescriptionKey: localizedDescription,
                                           NSLocalizedFailureReasonErrorKey: localizedFailureReason]
            failedToPlayWithError(URLError(.badURL, userInfo: userInfo))
            return
        }
        
        self.status = .unknown
        
        let keys = keysOfAVURLAssetLoadValuesAsynchronously
        let urlAsset = AVURLAsset(url: url)
        self.avURLAsset = urlAsset
        urlAsset.loadValuesAsynchronously(forKeys: keys) { [weak self] in
            DispatchQueue.main.async {
                self?.prepareToPlayAsset(urlAsset, withKeys: keys)
            }
        }
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
        self.avPlayer?.replaceCurrentItem(with: playerItem)
    }
    
    
    
    // MARK: - 播放错误
    func failedToPlayWithError(_ error: Error?) {
        self.error = error
        self.status = .error
    }
    
    /// 从出错的情况下恢复播放 (一般处理收到mediaServicesWereResetNotification)
    /// 调试方法：系统Settings -> Development -> Reset Media Services
    /// 相关介绍：https://developer.apple.com/library/archive/qa/qa1749/_index.html
    @objc
    func recoverPlaybackFromError() {
        guard let player = self.avPlayer, self.avURLAsset != nil else {
            return
        }
//        self.pendingSeekTime = self.playerItem?.currentTime()
        self.avPlayer = nil
        self.avPlayerItem = nil
        player.replaceCurrentItem(with: nil)
        if isPlaying {
            play()
        } else {
            pause()
        }
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
    
    /// 处理偶尔当AVPlayerItem的isPlaybackLikelyToKeepUp为true的时候无法自动进行播放
    func resumeIfNeeded() {
        if let playerItem = self.avPlayer?.currentItem,
            playerItem.status != .failed && self.isPlaying {
            setRate(1)
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
    
    // MARK: - 后台在线加载音频支持(支持后台处理mediaServicesWereResetNotification)
    
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
    
    // Time Observer Management
    private func addPeriodicTimerObserver(for player: AVPlayer) {
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
    
    private func removePeriodicTimerObserver(forPlayer player: AVPlayer) {
        if let timeObserverToken = self.periodicTimerObserverToken {
            player.removeTimeObserver(timeObserverToken)
            self.periodicTimerObserverToken = nil
        }
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
    
    open func cleanNowPlayingInfo() {
        self.nowPlayingInfo = [:]
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }
    
    
    /// MARK: - 远程命令
    func shouldReceiveRemoteEventsAdjustment() {
        setRemoteCommandEventsEnabled(self.shouldReceiveRemoteEvents)
    }
    
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
    
    /// 收到远程控制命令的回调
    @objc
    private func didReceiveRemoteCommandEvent(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        guard self.shouldReceiveRemoteEvents else { return .commandFailed }
        if let status = delegate?.player(self, handleRemoteCommandEvent: event) {
            return status
        }
        return handleRemoteCommandEvent(event)
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
            togglePlay()
        default:
            return .commandFailed
        }
        return .success
    }
    
    
    // MARK: - KVO & Notification Observers
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
    
    open func didPlayToEndTime(_ playerItem: AVPlayerItem) {}
    
    /// 音频中断通知
    @objc
    private func audioSessionInterruption(_ notification: Notification) {
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
    private func audioSessionRouteChange(_ notification: Notification) {
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
    private func playerItemOthersNotifier(_ notification: Notification) {
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
    private func effectiveRateChanged(_ notification: Notification) {
        DispatchQueue.runOnMainThreadSafely {
            self.detectWaitingForPlayback()
        }
    }
    
    @objc
    private func playerItemDidPlayToEndTime(_ notification: Notification) {
        guard let playerItem = notification.object as? AVPlayerItem,
            playerItem.isEqual(self.avPlayerItem) else {
                return
        }
        
        DispatchQueue.runOnMainThreadSafely {
            self.delegate?.playerDidPlayToEndTime(self)
        }
        
        didPlayToEndTime(playerItem)
    }
    
    /// UIApplication生命周期事件处理
    @objc
    private func applicationLifeCycleHandler(_ notification: Notification) {
        switch notification.name {
        case UIApplication.didEnterBackgroundNotification:
            beginBackgroundTaskIfNeeded()
        case UIApplication.didBecomeActiveNotification:
            endBackgroundTaskIfNeeded()
        default:
            break
        }
    }
    
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
    
    /// do not override this method.
    public final func reset() {
        DispatchQueue.checkOnMainThread()
        defer {
            self.delegate?.playerWasReset(self)
        }
        stop()
        cleanNowPlayingInfo()
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


extension DispatchQueue {
    class func runOnMainThreadSafely(_ execute: @escaping () -> Void) {
        if Thread.current.isMainThread {
            execute()
        } else {
            DispatchQueue.main.async(execute: execute)
        }
    }
    
    @inlinable class func checkOnMainThread(_ aSelector: Selector = #function) {
        if !Thread.current.isMainThread {
            fatalError(NSStringFromSelector(aSelector) + " should be on main thread!")
        }
    }
}


extension AVPlayerItem {
    var isLoadCompleted: Bool {
        guard duration.isValid, let timeRange = loadedTimeRanges.first?.timeRangeValue else { return false }
        return timeRange.isValid && timeRange.start == .zero && timeRange.end == duration
    }
    
    func isContainsTimeInLoadedTimeRanges(_ time: CMTime) -> Bool {
        guard time.isValid else { return false }
        return self.loadedTimeRanges.contains {
            let timeRange = $0.timeRangeValue
            return timeRange.containsTime(time) && (timeRange.end - time).seconds > 1
        }
    }
}

extension MPRemoteCommandCenter {
    var commonCommands: [MPRemoteCommand] {
        var commands: [MPRemoteCommand] = [pauseCommand,
                                           playCommand,
                                           stopCommand,
                                           togglePlayPauseCommand,
                                           changePlaybackRateCommand,
                                           nextTrackCommand,
                                           previousTrackCommand,
                                           skipForwardCommand,
                                           skipBackwardCommand,
                                           seekForwardCommand,
                                           seekBackwardCommand]
        if #available(iOS 9.1, *) {
            commands.append(changePlaybackPositionCommand)
        }
        return commands
    }
}
