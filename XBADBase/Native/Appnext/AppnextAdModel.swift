//
//  AppnextAdModel.swift
//  XBADBaseDemo
//
//  Created by 全尼古拉斯 on 2020/3/30.
//  Copyright © 2020 全尼古拉斯. All rights reserved.
//

import Foundation
import ObjectMapper
class AppnextAdModel: NSObject, Mappable {
    var api: AppnextNativeAdsSDKApi?
    var adData: AppnextAdData?
    override init() {
    }
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        api <- map["api"]
        adData <- map["adData"]
        
    }
}

