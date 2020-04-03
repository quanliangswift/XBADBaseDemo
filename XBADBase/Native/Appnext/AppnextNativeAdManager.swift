//
//  AppnextNativeAdManager.swift
//  TopNews_SV
//
//  Created by xb on 2019/7/9.
//  Copyright © 2019 xb. All rights reserved.
//

import UIKit

class AppnextNativeAdManager: NSObject, checkErrorProtocol  {
    static let shared = AppnextNativeAdManager()
    //预加载的广告池 Appnext
    var isFirstPreloadingAppnextAdes : Bool = true
    var preloadingAppnextAdes : [String : [(AppnextAdModel, TimeInterval)]] = [:]
    
    var appnextError: [String: [Int: XbAdErrorItem]] = [:]
    
    var appnextAdDownloaders: [String : AppnextAdDownloader?] = [:]
}
extension AppnextNativeAdManager {
    
    func getAppnextNativeAd(placementId : String) -> (Bool,AppnextAdModel?) {
        if preloadingAppnextAdes[placementId] == nil {
            preloadingAppnextAdes[placementId] = []
        }
        
        checkTimeout(placementId: placementId)
        var result: (Bool,AppnextAdModel?) = (false,nil)
        if !preloadingAppnextAdes[placementId]!.isEmpty {
            if let tempAd = preloadingAppnextAdes[placementId]!.first?.0 {
                preloadingAppnextAdes[placementId]!.removeFirst()
                result = (true,tempAd)
            }
        }
        fetchPreloadingAppnextAds(placementId : placementId)
        return result
        
    }
    func checkTimeout(placementId: String) {
        //获取广告之前检查缓存时间超过2小时
        let cacheValidTime = AdvertConfig.shared.config?.appnextAd.cacheValidTime ?? 60 * 60
        preloadingAppnextAdes[placementId] = preloadingAppnextAdes[placementId]?.filter{
            return (Date().timeIntervalSince1970 - $1) < cacheValidTime
        }
    }
    func fetchPreloadingAppnextAds(placementId : String) {
        if preloadingAppnextAdes[placementId] == nil {
            preloadingAppnextAdes[placementId] = []
        }
        let cacheSize = AdvertConfig.shared.config?.appnextAd.cacheSize ?? 3
        while preloadingAppnextAdes[placementId]!.count >= cacheSize {
            return
        }
        if appnextAdDownloaders[placementId] != nil {
            return
        }
        let startTime = Date().timeIntervalSince1970
        
        //            限频操作
        if let frequencyItems = AdvertConfig.shared.config?.frequencyControl?.appnext, let errorItems = self.appnextError[placementId] {
            
            let result = self.checkErrorCode(frequencyItems: frequencyItems, errorDic: errorItems)
            if !result.0 {
                var loadInfoItem: [String: Any] = [:]
                loadInfoItem["ad"] = ["id": "",
                                      "source": "appnext",
                                      "placement_id": placementId]
                loadInfoItem["result"] = ["success": false,
                                          "error": XbAdError.NATIVE_AD_NO_MORE_TRY_ERROR_CODE,
                                          "placement_id": placementId,
                                          "msg": XbAdError.NATIVE_AD_MSG_NO_MORE_TRY,
                                          "trigger_code": result.1]
                AdvertConfig.shared.sspLoadCallback?((source: "appnext", placementId: placementId, success: false, error: XbAdError.NATIVE_AD_NO_MORE_TRY_ERROR_CODE , msg: XbAdError.NATIVE_AD_MSG_NO_MORE_TRY, duration: Date().timeIntervalSince1970 - startTime, groupLoadInfo: [loadInfoItem]))
                return
            }
        }
        let cache = AppnextAdDownloader()
        cache.cacheCallBack = { (id, errorCode, msg, placementID, adModel) in
            
            if adModel != nil {
                
                self.preloadingAppnextAdes[placementID]!.append((adModel!, Date().timeIntervalSince1970))
                
                AdvertConfig.shared.sspLoadCallback?((source: "appnext", placementId: placementID, success: true, error: nil, msg: nil, duration: Date().timeIntervalSince1970 - startTime, groupLoadInfo: []))
                self.appnextError[placementID] = nil
            } else {
                AdvertConfig.shared.sspLoadCallback?((source: "appnext", placementId: placementID, success: false, error: errorCode, msg: msg, duration: Date().timeIntervalSince1970 - startTime, groupLoadInfo: []))
                
                //                    广告请求的报错记录
                if let errorItems = self.appnextError[placementID] {
                    if let error = errorItems[errorCode] {
                        let tempError = error
                        tempError.count += 1
                        tempError.time = Date().timeIntervalSince1970
                        self.appnextError[placementID]?[errorCode] = tempError
                    } else {
                        let tempError = XbAdErrorItem()
                        tempError.count = 1
                        tempError.time = Date().timeIntervalSince1970
                        self.appnextError[placementID]?[errorCode] = tempError
                    }
                    
                } else {
                    var errorDic: [Int: XbAdErrorItem] = [:]
                    let tempError = XbAdErrorItem()
                    tempError.count = 1
                    tempError.time = Date().timeIntervalSince1970
                    errorDic[errorCode] = tempError
                    self.appnextError[placementID] = errorDic
                }
            }
            _ = DelayTimer.delay(AdvertConfig.shared.config?.appnextAd.reqIntervalTime ?? 15, task: {
                self.appnextAdDownloaders[placementId] = nil
                self.fetchPreloadingAppnextAds(placementId: placementId)
            })
        }
        cache.cacheAd(placementId: placementId)
        self.appnextAdDownloaders[placementId] = cache
    }    
}

