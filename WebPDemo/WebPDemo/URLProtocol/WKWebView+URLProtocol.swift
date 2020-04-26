//
//  WKWebView+URLProtocol.swift
//  WebPDemo
//
//  Created by wuweixin on 2020/4/26.
//  Copyright © 2020 weixinwu. All rights reserved.
//

import WebKit


public extension URLProtocol {
    static let contextControllerClass: NSObject.Type? = {
        if let controller = WKWebView().value(forKey: "browsingContextController") as? NSObject {
            return object_getClass(controller) as? NSObject.Type
        }
        return nil
    }()
    
    @inlinable
    static var registerSchemeSelector: Selector {
        return NSSelectorFromString("registerSchemeForCustomProtocol:")
    }
    
    @inlinable
    static var unregisterSchemeSelector: Selector {
        return NSSelectorFromString("unregisterSchemeForCustomProtocol:")
    }
    
    static func registerWebScheme(_ scheme: String) {
        contextControllerClassPerform(registerSchemeSelector, scheme: scheme as NSString)
    }
    
    static func unregisterWebScheme(_ scheme: String) {
        contextControllerClassPerform(unregisterSchemeSelector, scheme: scheme as NSString)
    }
    
    static func contextControllerClassPerform(_ aSelector: Selector, scheme: NSString) {
        guard let aClass = self.contextControllerClass else {
            return
        }
        
        if aClass.responds(to: aSelector) {
            aClass.perform(aSelector, with: scheme)
        }
    }
}
