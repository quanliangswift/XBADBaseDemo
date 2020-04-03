//
//  GoogleNativeAdManager.swift
//  TopNews
//  非聚合缓存
//  Created by xb on 2018/5/3.
//  Copyright © 2018年 xb. All rights reserved.
//

import UIKit
import GoogleMobileAds
class GoogleNativeAdManager: NSObject, checkErrorProtocol  {
    static let shared = GoogleNativeAdManager()

    //预加载的广告池 Google
    var isFirstPreloadingGoogleAdes : Bool = true
    var preloadingGoogleAdes : [String : [(GADUnifiedNativeAd, TimeInterval)]] = [:]
    var admobError: [String: [Int: XbAdErrorItem]] = [:]
    var googleAdDownloaders: [String : GoogleAdDownloader?] = [:]
}
extension GoogleNativeAdManager {
    
    func getGoogleNativeAd(adUnitID : String) -> (Bool,GADUnifiedNativeAd?) {
        if preloadingGoogleAdes[adUnitID] == nil {
            preloadingGoogleAdes[adUnitID] = []
        }
        
        checkTimeout(placementId: adUnitID)
        var result: (Bool,GADUnifiedNativeAd?) = (false,nil)
        if !preloadingGoogleAdes[adUnitID]!.isEmpty {
            if let tempAd = preloadingGoogleAdes[adUnitID]!.first?.0 {
                preloadingGoogleAdes[adUnitID]!.removeFirst()
                result = (true,tempAd)
            }
        }
        fetchPreloadingGoogleAds(adUnitID : adUnitID)
        return result
    }
    
    func checkTimeout(placementId: String) {
        //获取广告之前检查缓存时间超过2小时
        let cacheValidTime =  AdvertConfig.shared.config?.googleAd.cacheValidTime ?? 60 * 60
        preloadingGoogleAdes[placementId] = preloadingGoogleAdes[placementId]?.filter{
            return (Date().timeIntervalSince1970 - $1) < cacheValidTime
        }
    }
    
    func fetchPreloadingGoogleAds(adUnitID : String) {
        if preloadingGoogleAdes[adUnitID] == nil {
            preloadingGoogleAdes[adUnitID] = []
        }
        let cacheSize = AdvertConfig.shared.config?.googleAd.cacheSize ?? 3
        while preloadingGoogleAdes[adUnitID]!.count >= cacheSize {
            return
        }
        if googleAdDownloaders[adUnitID] != nil {
            return
        }
        let startTime = Date().timeIntervalSince1970
        
        //            限频操作
        if let frequencyItems = AdvertConfig.shared.config?.frequencyControl?.admob, let errorItems = self.admobError[adUnitID] {
            
            let result = self.checkErrorCode(frequencyItems: frequencyItems, errorDic: errorItems)
            if !result.0 {
                var loadInfoItem: [String: Any] = [:]
                loadInfoItem["ad"] = ["id": "",
                                      "source": "admob",
                                      "placement_id": adUnitID]
                loadInfoItem["result"] = ["success": false,
                                          "error": XbAdError.NATIVE_AD_NO_MORE_TRY_ERROR_CODE,
                                          "placement_id": adUnitID,
                                          "msg": XbAdError.NATIVE_AD_MSG_NO_MORE_TRY,
                                          "trigger_code": result.1]
//                self.logSSPAdvertLoad(source: "admob", placementId: adUnitID, success: false, error: XbAdError.NATIVE_AD_NO_MORE_TRY_ERROR_CODE , msg: XbAdError.NATIVE_AD_MSG_NO_MORE_TRY, duration: Date().timeIntervalSince1970 - startTime, groupLoadInfo: [loadInfoItem])
                AdvertConfig.shared.sspLoadCallback?((source: "admob", placementId: adUnitID, success: false, error: XbAdError.NATIVE_AD_NO_MORE_TRY_ERROR_CODE , msg: XbAdError.NATIVE_AD_MSG_NO_MORE_TRY, duration: Date().timeIntervalSince1970 - startTime, groupLoadInfo: [loadInfoItem]))
                return
            }
        }
        let cache = GoogleAdDownloader()
        cache.cacheCallBack = { (id, errorCode, msg, placementID, nativeAd) in
            
            if nativeAd != nil {
                
                self.preloadingGoogleAdes[placementID]!.append((nativeAd!, Date().timeIntervalSince1970))
                
//                self.logSSPAdvertLoad(source: "admob", placementId: placementID, success: true, error: nil, msg: nil, duration: Date().timeIntervalSince1970 - startTime, groupLoadInfo: [])
                AdvertConfig.shared.sspLoadCallback?((source: "admob", placementId: placementID, success: true, error: nil, msg: nil, duration: Date().timeIntervalSince1970 - startTime, groupLoadInfo: []))
                self.admobError[placementID] = nil
            } else {
//                self.logSSPAdvertLoad(source: "admob", placementId: placementID, success: false, error: errorCode, msg: msg, duration: Date().timeIntervalSince1970 - startTime, groupLoadInfo: [])
                AdvertConfig.shared.sspLoadCallback?((source: "admob", placementId: placementID, success: false, error: errorCode, msg: msg, duration: Date().timeIntervalSince1970 - startTime, groupLoadInfo: []))
                //                    广告请求的报错记录
                if let errorItems = self.admobError[placementID] {
                    if let error = errorItems[errorCode] {
                        let tempError = error
                        tempError.count += 1
                        tempError.time = Date().timeIntervalSince1970
                        self.admobError[placementID]?[errorCode] = tempError
                    } else {
                        let tempError = XbAdErrorItem()
                        tempError.count = 1
                        tempError.time = Date().timeIntervalSince1970
                        self.admobError[placementID]?[errorCode] = tempError
                    }
                    
                } else {
                    var errorDic: [Int: XbAdErrorItem] = [:]
                    let tempError = XbAdErrorItem()
                    tempError.count = 1
                    tempError.time = Date().timeIntervalSince1970
                    errorDic[errorCode] = tempError
                    self.admobError[placementID] = errorDic
                }
            }
            
            _ = DelayTimer.delay(AdvertConfig.shared.config?.googleAd.reqIntervalTime ?? 15, task: {
                self.googleAdDownloaders[adUnitID] = nil
                self.fetchPreloadingGoogleAds(adUnitID : adUnitID)
            })
        }
        cache.cacheAd(placementId: adUnitID)
        self.googleAdDownloaders[adUnitID] = cache
        
    }
}

