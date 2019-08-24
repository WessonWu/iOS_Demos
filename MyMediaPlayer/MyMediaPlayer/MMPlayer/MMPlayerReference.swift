//
//  播放器状态
//

import UIKit
import MediaPlayer

public enum MMPlayerStatus: Int {
    case unknown = 0
    case readyToPlay = 1
    case error = 2
}

extension MMPlayerStatus: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        switch self {
        case .unknown:
            return "unknown"
        case .readyToPlay:
            return "readyToPlay"
        case .error:
            return "error"
        }
    }
    
    public var debugDescription: String {
        return description
    }
}

public enum MMPlayMode: Int {
    case listCycle = 0 // 列表循环
    case singleCycle = 1 // 单曲循环
    case randomPlay = 2 // 随机播放
}

extension MMPlayMode: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        switch self {
        case .listCycle:
            return "listCycle"
        case .singleCycle:
            return "singleCycle"
        case .randomPlay:
            return "randomPlay"
        }
    }
    
    public var debugDescription: String {
        return description
    }
}

public enum MMPlaybackState: Int {
    case playing = 1
    case paused = 2
    case stopped = 3
}

extension MMPlaybackState: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        switch self {
        case .playing:
            return "playing"
        case .paused:
            return "paused"
        case .stopped:
            return "stopped"
        }
    }
    
    public var debugDescription: String {
        return description
    }
}


/// 音频中断上下文
public struct AudioSessionInterruptionContext {
    public let type: AVAudioSession.InterruptionType
    public let options: AVAudioSession.InterruptionOptions?
    
    private let _wasSuspened: Bool
    @available(iOS 10.3, *)
    public var wasSuspened: Bool {
        return _wasSuspened
    }
    
    public init(type: AVAudioSession.InterruptionType, options: AVAudioSession.InterruptionOptions?) {
        self.type = type
        self.options = options
        self._wasSuspened = false
    }
    
    @available(iOS 10.3, *)
    public init (type: AVAudioSession.InterruptionType, options: AVAudioSession.InterruptionOptions?, wasSuspened: Bool) {
        self.type = type
        self.options = options
        self._wasSuspened = wasSuspened
    }
}


public struct AudioSessionRouteChangeContext {
    public let reason: AVAudioSession.RouteChangeReason
    public let previousRouteDescription: AVAudioSessionRouteDescription?
    
    public init(reason: AVAudioSession.RouteChangeReason, previousRouteDescription: AVAudioSessionRouteDescription?) {
        self.reason = reason
        self.previousRouteDescription = previousRouteDescription
    }
}


public protocol MMPlayerDelegate: AnyObject {
    func player(_ player: MMPlayer, mediaItemDidSet newItem: MMItemType?, oldItem: MMItemType?)
    func player(_ player: MMPlayer, playerStatusDidSet newStatus: MMPlayerStatus, oldStatus: MMPlayerStatus)
    func player(_ player: MMPlayer, playbackStateDidSet newState: MMPlaybackState, oldState: MMPlaybackState)
    func player(_ player: MMPlayer, currentTimeDidChanged currentTime: CMTime, duration: CMTime)
    func player(_ player: MMPlayer, loadedTimeRangesDidChanged timeRanges: [CMTimeRange])
    func player(_ player: MMPlayer, retriveArtworkImageWithURL url: URL, completion: @escaping (UIImage?) -> Void)
    func playerDidPlayToEndTime(_ player: MMPlayer)
    func player(_ player: MMPlayer, handleRemoteCommandEvent event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus?
    /// 音频中断(电话、语音或其他App)
    ///
    /// - Parameters:
    ///   - player: 收到音频中断的播放器
    ///   - context: 音频中断上下文
    func player(_ player: MMPlayer, didReceiveAudioSessionInterruption context: AudioSessionInterruptionContext)
    /// 音频输入输出改变
    ///
    /// - Parameters:
    ///   - player: 收到事件的播放器
    ///   - context: 音频输入输出改变上下文
    func player(_ player: MMPlayer, didReceiveAudioSessionRouteChange context: AudioSessionRouteChangeContext)
    func playerWasReset(_ player: MMPlayer)
}

extension MMPlayerDelegate {
    func player(_ player: MMPlayer, mediaItemDidSet newItem: MMItemType?, oldItem: MMItemType?) {}
    func player(_ player: MMPlayer, playerStatusDidSet newStatus: MMPlayerStatus, oldStatus: MMPlayerStatus) {}
    func player(_ player: MMPlayer, playbackStateDidSet newState: MMPlaybackState, oldState: MMPlaybackState) {}
    func player(_ player: MMPlayer, currentTimeDidChanged currentTime: CMTime, duration: CMTime) {}
    func player(_ player: MMPlayer, loadedTimeRangesDidChanged timeRanges: [CMTimeRange]) {}
    func player(_ player: MMPlayer, retrieveArtworkImageWithURL url: URL, completion: @escaping (UIImage?) -> Void) {
        completion(nil)
    }
    func player(_ player: MMPlayer, failedToPlayWith error: Error) {}
    func playerDidPlayToEndTime(_ player: MMPlayer) {}
    func player(_ player: MMPlayer, handleRemoteCommandEvent event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus? {
        return nil
    }
    func player(_ player: MMPlayer, didReceiveAudioSessionInterruption context: AudioSessionInterruptionContext) {}
    func player(_ player: MMPlayer, didReceiveAudioSessionRouteChange context: AudioSessionRouteChangeContext) {}
    func playerWasReset(_ player: MMPlayer) {}
}

public protocol MMQueuePlayerDelegate: MMPlayerDelegate {
    func player(_ player: MMPlayer, playModeDidSet newMode: MMPlayMode, oldModel: MMPlayMode)
}

extension MMQueuePlayerDelegate {
    func player(_ player: MMPlayer, playModeDidSet newMode: MMPlayMode, oldModel: MMPlayMode) {}
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
