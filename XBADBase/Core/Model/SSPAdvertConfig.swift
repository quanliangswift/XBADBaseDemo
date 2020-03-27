//
//  AdvertConfig.swift
//  XBADBaseDemo
//
//  Created by 全尼古拉斯 on 2020/3/26.
//  Copyright © 2020 全尼古拉斯. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftyJSON

class SSPAdvertConfig : Mappable {
    // 填充后移， 若为true，则广告填充发生在willdisplay， 否则在拿到数据的时候就处理
    var lazyFill : Bool = false
    var detailBannerAds: [DetailBannerAd] = []
    var frequencyControl: FrequencyControl?
    
    var facebookAd: ConfigItem = ConfigItem()
    var googleAd: ConfigItem = ConfigItem()
    var baiduAd: ConfigItem = ConfigItem()
    var appnextAd: ConfigItem = ConfigItem()
    var mintegralAd: ConfigItem = ConfigItem()
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        // MARK: - lazyFill的key改为lazyfill，不用lazy_fill, 目的是不接受原来的配置，，新逻辑不适用lazy_fill
        lazyFill <- map["lazyfill"]
        detailBannerAds <- map["detail_banner_ads"]
        frequencyControl <- map["placement_frequency_control"]
  
        facebookAd <- map["facebook_ad"]
        googleAd <- map["google_ad"]
        baiduAd <- map["baidu_ad"]
        appnextAd <- map["appnext_ad"]
        mintegralAd <- map["mintegral_ad"]
    }
}
class ConfigItem: NSObject, Mappable {
    var cacheSize: Int = 2
    var cacheValidTime: Double = 60 * 60
    var reqIntervalTime : Double = 15
    required init?(map: Map) {
    }
    override init() {
        super.init()
    }
    func mapping(map: Map) {
        cacheSize <- map["cache_size"]
        cacheValidTime <- map["cache_valid_time"]
        reqIntervalTime <- map["req_interval_time"]
    }
}
class DetailBannerAd: Mappable {
    var source : String?
    var placement: String?
    init() {
    }
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        source <- map["source"]
        placement <- map["placement"]
    }
}
