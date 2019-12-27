//
//  MMPlayerView.swift
//  MyMediaPlayer
//
//  Created by wuweixin on 2019/12/26.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit
import AVFoundation

open class MMPlayerView: UIView {
    open override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    public func setPlayer(_ player: AVPlayer) {
        playerLayer.player = player
    }
}
