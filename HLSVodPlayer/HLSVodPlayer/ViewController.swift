//
//  ViewController.swift
//  HLSVodPlayer
//
//  Created by wuweixin on 2019/12/27.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit
import AVKit

class ViewController: UIViewController {
    let dispatchQueue = DispatchQueue(label: "cn.wessonwu.demos.HLSVodPlayer.resourceLoader")

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func onPlayPressed(_ sender: Any) {
        let vc = AVPlayerViewController()
        
        let urlAsset = AVURLAsset(url: URL(string: "http://localhost:8080/files/test.m3u8")!)
        urlAsset.resourceLoader.setDelegate(self, queue: dispatchQueue)
        
        let playerItem = AVPlayerItem(asset: urlAsset)
        vc.player = AVPlayer(playerItem: playerItem)
        self.present(vc, animated: true, completion: nil)
    }
    
    func shouldLoadOrRenewRequestedResource(_ loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        guard let url = loadingRequest.request.url,
            url.pathExtension == "key" else {
            return false
        }
        let keyServerURL = url
        var request = URLRequest(url: keyServerURL)
        request.addValue("test", forHTTPHeaderField: "TOKEN") // 添加验证(该例子只用了简单的验证)
        URLSession.shared.dataTask(with: request) { (data, resp, error) in
            self.dispatchQueue.async {
                if let ckcData = data {
                    loadingRequest.dataRequest?.respond(with: ckcData)
                    loadingRequest.contentInformationRequest?.contentType = AVStreamingKeyDeliveryContentKeyType
                    loadingRequest.finishLoading()
                } else {
                    loadingRequest.finishLoading(with: error)
                }

            }
        }
        .resume()
        return true
    }
    
}

extension ViewController: AVAssetResourceLoaderDelegate {
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        return shouldLoadOrRenewRequestedResource(loadingRequest)
    }
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForRenewalOfRequestedResource renewalRequest: AVAssetResourceRenewalRequest) -> Bool {
        return shouldLoadOrRenewRequestedResource(renewalRequest)
    }
}

