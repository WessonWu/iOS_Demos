//
//  SimpleAPIModel.swift
//  Thor_Example
//
//  Created by zhengxu on 2018/5/25.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import Foundation
import HandyJSON
/*
 userId: 3,
 id: 27,
 title: "quasi id et eos tenetur aut quo autem",
 body
 */

struct SimpleAPIModel:HandyJSON {
    
    
    var data:[Special] = []
}

struct Special:HandyJSON {
    
    
    var dateline : String!
    var id : String!
    var name : String!
    var pic : String!
    var type : String!
}
