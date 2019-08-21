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


public protocol MMPlayerDelegate: AnyObject {
    func player(_ player: MMPlayer, currentTimeDidChanged currentTime: CMTime, duration: CMTime)
    func player(_ player: MMPlayer, loadedTimeRangesDidChanged timeRanges: [CMTimeRange])
    func player(_ player: MMPlayer, retriveArtworkImageWithURL url: URL, completion: @escaping (UIImage?) -> Void)
    func player(_ player: MMPlayer, handleRemoteCommandEvent event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus?
}

extension MMPlayerDelegate {
    func player(_ player: MMPlayer, currentTimeDidChanged currentTime: CMTime, duration: CMTime) {}
    func player(_ player: MMPlayer, loadedTimeRangesDidChanged timeRanges: [CMTimeRange]) {}
    func player(_ player: MMPlayer, retrieveArtworkImageWithURL url: URL, completion: @escaping (UIImage?) -> Void) {
        completion(nil)
    }
    func player(_ player: MMPlayer, handleRemoteCommandEvent event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus? {
        return nil
    }
}
