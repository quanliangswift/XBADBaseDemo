//
//  MTGAdModel.swift
//  XBADBaseDemo
//
//  Created by 全尼古拉斯 on 2020/3/30.
//  Copyright © 2020 全尼古拉斯. All rights reserved.
//

import Foundation
import ObjectMapper

class MTGAdModel: NSObject, Mappable {
    var nativeAd: MTGCampaign?
    var manager: MTGNativeAdManager?
    override init() {
    }
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        nativeAd <- map["nativeAd"]
        manager <- map["manager"]
        
    }
}
