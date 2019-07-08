//
//  播放源
//

import UIKit

public enum MMItemArtwork {
    case none
    case url(URL)
    case image(UIImage)
}

extension MMItemArtwork: Equatable {
    public static func == (lhs: MMItemArtwork, rhs: MMItemArtwork) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            return true
        case let (.url(url1), .url(url2)):
            return url1 == url2
        case let (.image(image1), image(image2)):
            return image1 == image2
        default:
            return false
        }
    }
}

public protocol MMItemType {
    var uniqueID: String { get } // 唯一ID，区分不同MMItem
    var assetURL: URL? { get } // 资源URL
    var artist: String { get } // 艺术家
    var title: String { get } // 标题
    var artwork: MMItemArtwork? { get } // 封面
    var duration: TimeInterval { get } // 时长
}

extension Equatable where Self: MMItemType {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.uniqueID == rhs.uniqueID
    }
}

extension Hashable where Self: MMItemType {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.uniqueID)
    }
}

public struct MMItem: MMItemType {
    public var uniqueID: String
    public var assetURL: URL?
    public var artist: String
    public var title: String
    public var artwork: MMItemArtwork?
    public var duration: TimeInterval
    
    public init(uniqueID: String,
                assetURL: URL?,
                artist: String,
                title: String,
                artwork: MMItemArtwork?,
                duration: TimeInterval) {
        self.uniqueID = uniqueID
        self.assetURL = assetURL
        self.artist = artist
        self.title = title
        self.artwork = artwork
        self.duration = duration
    }
    
    public init(item: MMItemType) {
        self.init(uniqueID: item.uniqueID,
                  assetURL: item.assetURL,
                  artist: item.artist,
                  title: item.title,
                  artwork: item.artwork,
                  duration: item.duration)
    }
}
