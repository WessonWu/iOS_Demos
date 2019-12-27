//
//  MMPlayerResourceLoaderProxy.swift
//  MyMediaPlayer
//
//  Created by wuweixin on 2019/12/26.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import AVFoundation

open class MMPlayerResourceLoaderProxy: NSObject, AVAssetResourceLoaderDelegate {
    let dispatchQueue = DispatchQueue(label: "cn.wessonwu.mmplayer.resourceLoaderProxy")
}
