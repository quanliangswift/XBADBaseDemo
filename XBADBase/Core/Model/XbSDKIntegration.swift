//
//  XbSDKIntegration.swift
//  TopNews
//
//  Created by xb on 2019/3/21.
//  Copyright © 2019年 xb. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftyJSON

class XbAdIntegration: NSObject, Mappable {
    var nativeAds: [XbSDKIntegration] = []
    var rewardedVideoAds: [XbSDKIntegration] = []
    var interstitialAds: [XbSDKIntegration] = []
    var nativeAdsJson: JSON?
    var rewardedVideoAdsJson: JSON?
    var interstitialAdsJson: JSON?

    override init() {
        super.init()
    }
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        nativeAds <- map["data"]
        rewardedVideoAds <- map["reward_video_data"]
        interstitialAds <- map["interstitial_data"]
        nativeAdsJson <- map["data"]
        rewardedVideoAdsJson <- map["reward_video_data"]
        interstitialAdsJson <- map["interstitial_data"]

    }
}

class XbSDKIntegration: NSObject, Mappable {
    
    var priority: Int = 0
    var cacheSize : Int?
    var sdkGroup : [SDKGroupItem]?
    //  每次获取的格子数
    var slots : Int?
    var xbPlacement : String?
    var enable: Int?
    var duplicate: Int?
    var refresdCd: Double = 3000
    var frequencyControl: FrequencyControl?
    var headTimesSpecial: HeadTimesSpecial?
    // 并发缓存的超时时间
    var concurrentReqTimeout: Double = 15
    // 是否使用并发请求缓存
    var concurrency: Bool = false
    override init() {
        super.init()
    }
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        priority <- map["priority"]
        cacheSize <- map["cache_size"]
        sdkGroup <- map["sdk_group"]
        slots <- map["slots"]
        enable <- map["enable"]
        xbPlacement <- map["xb_placement"]
        duplicate <- map["duplicate"]
        refresdCd <- map["refresh_cd"]
        frequencyControl <- map["placement_frequency_control"]
        headTimesSpecial <- map["head_times_special"]
        concurrency <- map["concurrency"]
        concurrentReqTimeout <- map["concurrent_req_timeout"]

    }
}


struct SDKGroupItem: Mappable {
    var cacheValidTime : Double?
    var placement : String?
    var price : Double = 0
    var source : String?
    var reqIntervalTime : Double = 0
    
    var lastLoadAdTime: Double = 0
//    本地数据
    var title: String?
    var desc: String?
    var cacheTime: Double?
    var groupLoadInfo: [[String: Any]] = []
    var nativeAd: Any?
    
    
    init?(map: Map) {
    }
    init() {
    }
    mutating func mapping(map: Map) {
        cacheValidTime <- map["cache_valid_time"]
        placement <- map["placement"]
        price <- map["price"]
        source <- map["source"]
        reqIntervalTime <- map["req_interval_time"]

        lastLoadAdTime <- map["lastLoadAdTime"]
        title <- map["title"]
        desc <- map["desc"]
        groupLoadInfo <- map["group_load_info"]
        nativeAd <- map["nativeAd"]
    }
    func equals(compareTo: SDKGroupItem) -> Bool {
        return cacheValidTime == compareTo.cacheValidTime
            && placement == compareTo.placement
            && price == compareTo.price
            && source == compareTo.source
    }
}
class HeadTimesSpecial: NSObject, Mappable {
    var specifiedTimes: Int = 0
    var start: Int = 0
    override init() {
        super.init()
    }
    required init?(map: Map) {
    }
    func mapping(map: Map) {
        specifiedTimes <- map["specified_times"]
        start <- map["start"]
    }
}

class FrequencyControl: NSObject, Mappable {
    var facebook = [FrequencyControlItem]()
    var admob = [FrequencyControlItem]()
    var baidu = [FrequencyControlItem]()
    var appnext = [FrequencyControlItem]()
    var mintegral = [FrequencyControlItem]()
    var applovin = [FrequencyControlItem]()
    override init() {
        super.init()
    }
    required init?(map: Map) {
    }
    func mapping(map: Map) {
        facebook <- map["facebook"]
        admob <- map["admob"]
        baidu <- map["baidu"]
        appnext <- map["appnext"]
        mintegral <- map["mintegral"]
        applovin <- map["applovin"]
    }
}

class FrequencyControlItem: NSObject, Mappable {
    var code: Int?
    var threshold: Int = 1
    var wait: Double = 0
    var exponential: Int = 1
    override init() {
        super.init()
    }
    required init?(map: Map) {
    }
    func mapping(map: Map) {
        code <- map["code"]
        threshold <- map["threshold"]
        wait <- map["wait"]
        exponential <- map["exponential"]
    }
}


class XbAdError: NSObject, Mappable {
    static let NATIVE_AD_REDUNDANT_ERROR_CODE = 100
    static let NATIVE_AD_NO_MORE_TRY_ERROR_CODE = 101
    static let NATIVE_AD_REQ_INTERVAL_TIME_ERROR_CODE = 102
    static let NATIVE_AD_TIME_OUT_ERROR_CODE = 1000

    static let NATIVE_AD_MSG_REDUNDANT = "redundant"
    static let NATIVE_AD_MSG_NO_MORE_TRY = "no_more_try"
    static let NATIVE_AD_REQ_INTERVAL_TIME = "req_interval_time"

    static let NATIVE_AD_MSG_TIME_OUT = "等待20秒还没有结果"

    var adError: [String: [String: [Int: XbAdErrorItem]]] = [:]
//    var facebookError: [String: [Int: XbAdErrorItem]] = [:]
//    var admobError: [String: [Int: XbAdErrorItem]] = [:]
//    var baiduError: [String: [Int: XbAdErrorItem]] = [:]
//    var appnextError: [String: [Int: XbAdErrorItem]] = [:]
//    var mtgError: [String: [Int: XbAdErrorItem]] = [:]
//    var alError: [String: [Int: XbAdErrorItem]] = [:]
    
    override init() {
        super.init()
    }
    required init?(map: Map) {
    }
    func mapping(map: Map) {
        adError <- map["adError"]
//        facebookError <- map["facebookError"]
//        admobError <- map["admobError"]
//        baiduError <- map["baiduError"]
//        appnextError <- map["appnextError"]
//        mtgError <- map["mtgError"]
//        alError <- map["alError"]
    }
}

class XbAdErrorItem: NSObject, Mappable {
    var count : Int = 0
    var time : Double = 0
    override init() {
        super.init()
    }
    required init?(map: Map) {
    }
    func mapping(map: Map) {
        count <- map["count"]
        time <- map["time"]
    }
}

class ConfigWrapper: NSObject, Mappable {
    var config: [XbSDKIntegration] = []
    var publicEnable : Bool = false
    var publicIntegration: XbSDKIntegration?
    override init() {
        super.init()
    }
    required init?(map: Map) {
    }
    func mapping(map: Map) {
        config <- map["config"]
        publicEnable <- map["publicEnable"]
        publicIntegration <- map["publicIntegration"]
    }
}
