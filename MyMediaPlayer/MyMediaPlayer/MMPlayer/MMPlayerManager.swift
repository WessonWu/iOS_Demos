//
//  MMPlayerManager.swift
//  MyMediaPlayer
//
//  Created by wuweixin on 2019/12/26.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit
import AVFoundation

open class MMPlayerManager: NSObject {
    
    var resourceLoaderProxy: MMPlayerResourceLoaderProxy?
    var avURLAsset: AVURLAsset?
    var avPlayerItem: AVPlayerItem?
    var avPlayer: AVPlayer?
    
    open func play(for url: URL, options: [String: Any]? = nil) {
        let urlAsset = AVURLAsset(url: url, options: options)
        self.avURLAsset = urlAsset
        let proxy = MMPlayerResourceLoaderProxy()
        self.resourceLoaderProxy = proxy
        urlAsset.resourceLoader.setDelegate(proxy, queue: proxy.dispatchQueue)
        loadURLAsset(urlAsset)
    }
    
    // 1. prepare an asset for use
    func loadURLAsset(_ urlAsset: AVURLAsset) {
        let keys: [String] = ["playable"]
        urlAsset.loadValuesAsynchronously(forKeys: keys) { [weak self] in
            DispatchQueue.main.async {
                guard let strongSelf = self, strongSelf.avURLAsset == urlAsset else {
                    // 更换了新的或取消了
                    return
                }
                
                let errorRef = NSErrorPointer(nilLiteral: ())
                let trackStatus = urlAsset.statusOfValue(forKey: "playable", error: errorRef)
                switch trackStatus {
                case .loaded:
                    strongSelf.loadPlayerItem(with: urlAsset)
                case .failed:
                    strongSelf.report(errorRef: errorRef, for: urlAsset)
                case .cancelled:
                    // Do whatever is appropriate for cancelation.
                    break
                default:
                    // Do nothing.
                    break
                }
                
                strongSelf.loadPlayerItem(with: urlAsset)
            }
        }
    }
    
    // 2. prepare a playerItem for use
    func loadPlayerItem(with asset: AVURLAsset) {
        self.avPlayerItem = AVPlayerItem(asset: asset)
        
        self.avPlayer = AVPlayer(playerItem: self.avPlayerItem)
    }
    
    
    
    // report error when urlAsset.loadValuesAsynchronously failed
    func report(errorRef: NSErrorPointer, for urlAsset: AVURLAsset) {
        
    }
    
}
