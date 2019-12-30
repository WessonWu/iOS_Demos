//
//  ThorPagingParams.swift
//  Thor
//
//  Created by wuweixin on 2019/12/30.
//

import Foundation
import HandyJSON


public protocol PagingParamsCompatible {
    var startKey: String { get set }
    var total: Int64 { get set }
    var more: Bool { get set }
    
    /// 用于更新参数
    mutating func update(_ newParams: PagingParamsCompatible)
    /// 重置参数(当需要重新刷新的时候)
    mutating func reset()
    /// 请求错误需要回滚参数(根据需要，默认不实现)
    mutating func recover()
}

public extension PagingParamsCompatible {
    
    mutating func update(_ newParams: PagingParamsCompatible) {
        self.startKey = newParams.startKey
        self.total = newParams.total
        self.more = newParams.more
    }
    
    mutating func reset() {
        startKey = ""
        total = 0
        more = false
    }
    
    mutating func recover() {}
}

/// 默认的实现(线程不安全)
public struct PagingParams: PagingParamsCompatible {
    public var startKey: String = ""
    public var total: Int64 = 0
    public var more: Bool = false
    
    internal var savedState: PagingParamsCompatible?
    
    public init() {}
    
    public mutating func reset() {
        self.savedState = AutoPagingParamsParser(params: self)
        self.more = false
        self.total = 0
        self.startKey = ""
    }
    
    public mutating func recover() {
        guard let params = savedState else { return }
        self.startKey = params.startKey
        self.total = params.total
        self.more = params.more
        self.savedState = nil
    }
}

internal struct AutoPagingParamsParser: PagingParamsCompatible, HandyJSON {
    public var startKey: String = ""
    public var total: Int64 = 0
    public var more: Bool = false
    
    public init() {}
    public init(params: PagingParamsCompatible) {
        self.startKey = params.startKey
        self.total = params.total
        self.more = params.more
    }
}

