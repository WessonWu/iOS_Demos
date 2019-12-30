//
//  ThorTargetType.swift
//  Thor
//
//  Created by wuweixin on 2019/12/30.
//

import Moya

public protocol ThorTargetType: TargetType {
    
}


public extension ThorTargetType {
    var method: Moya.Method {
        return .get
    }
    
    var validationType: ValidationType {
        return .successCodes
    }
}
