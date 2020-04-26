//
//  WebPURLProtocol.swift
//  WebPDemo
//
//  Created by wuweixin on 2020/4/26.
//  Copyright © 2020 weixinwu. All rights reserved.
//

import Foundation
import Kingfisher
import KingfisherWebP

open class WebPURLProtocol: URLProtocol {
    open override class func canInit(with request: URLRequest) -> Bool {
        guard request.httpMethod == "GET",
            let url = request.url else {
            return false
        }
        // avoid recycle
        if request.value(forHTTPHeaderField: "WEBPURLPROTOCOL_HANDLED") == "HANDLED" {
            return false
        }
        return url.pathExtension == "webp"
    }
    
    open override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    open override func startLoading() {
        guard let url = request.url else {
            return
        }
        let allHTTPHeaderFields = request.allHTTPHeaderFields
        let requestModifier = AnyModifier { request in
            var request = request
            allHTTPHeaderFields?.forEach({ (entry) in
                request.addValue(entry.value, forHTTPHeaderField: entry.key)
            })
            request.addValue("HANDLED", forHTTPHeaderField: "WEBPURLPROTOCOL_HANDLED")
            return request
        }
        let options: KingfisherOptionsInfo = [
            .processor(WebPProcessor.default),
            .cacheSerializer(WebPSerializer.default),
            .requestModifier(requestModifier)
        ]
        KingfisherManager.shared.retrieveImage(
            with: url,
            options: options
        ) { [weak self] (result) in
            guard let strongSelf = self,
                let client = strongSelf.client else {
                return
            }
            switch result {
            case let .success(retrieved):
                let data = retrieved.image.pngData() ?? Data()
                client.urlProtocol(strongSelf, didLoad: data)
                client.urlProtocolDidFinishLoading(strongSelf)
            case let .failure(error):
                client.urlProtocol(strongSelf, didFailWithError: error)
            }
        }
    }
    
    open override func stopLoading() {
        
    }
}
