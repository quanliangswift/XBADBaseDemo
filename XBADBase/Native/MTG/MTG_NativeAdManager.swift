//
//  MTGNativeAdManager.swift
//  TopNews_SV
//
//  Created by xb on 2019/8/7.
//  Copyright © 2019 xb. All rights reserved.
//

import UIKit

class MTG_NativeAdManager: NSObject, checkErrorProtocol  {
    static let shared = MTG_NativeAdManager()
    
    
    //预加载的广告池 MTG
    var isFirstPreloadingMTGAdes : Bool = true
    var preloadingMTGAdes : [String : [(MTGAdModel, TimeInterval)]] = [:]
    
    var mtgError: [String: [Int: XbAdErrorItem]] = [:]
    var mtgAdDownloaders: [String : MTGAdDownloader?] = [:]
}
extension MTG_NativeAdManager {
    
    func getMTGNativeAd(adUnitID : String) -> (Bool,MTGAdModel?) {
        if preloadingMTGAdes[adUnitID] == nil {
            preloadingMTGAdes[adUnitID] = []
        }
        
        checkTimeout(placementId: adUnitID)
        var result: (Bool,MTGAdModel?) = (false,nil)
        if !preloadingMTGAdes[adUnitID]!.isEmpty {
            if let tempAd = preloadingMTGAdes[adUnitID]!.first?.0 {
                preloadingMTGAdes[adUnitID]!.removeFirst()
                result = (true,tempAd)
            }
        }
        fetchPreloadingMTGAds(adUnitID : adUnitID)
        return result
    }
    func checkTimeout(placementId: String) {
        //获取广告之前检查缓存时间超过2小时
        let cacheValidTime = AdvertConfig.shared.config?.mintegralAd.cacheValidTime ?? 60 * 60
        preloadingMTGAdes[placementId] = preloadingMTGAdes[placementId]?.filter{
            return (Date().timeIntervalSince1970 - $1) < cacheValidTime
        }
    }
    func fetchPreloadingMTGAds(adUnitID : String) {
       
        if preloadingMTGAdes[adUnitID] == nil {
            preloadingMTGAdes[adUnitID] = []
        }
        let cacheSize = AdvertConfig.shared.config?.mintegralAd.cacheSize ?? 3
        while preloadingMTGAdes[adUnitID]!.count >= cacheSize {
            return
        }
        if mtgAdDownloaders[adUnitID] != nil {
            return
        }
        let startTime = Date().timeIntervalSince1970
        //            限频操作
        if let frequencyItems = AdvertConfig.shared.config?.frequencyControl?.mintegral, let errorItems = self.mtgError[adUnitID] {
            
            let result = self.checkErrorCode(frequencyItems: frequencyItems, errorDic: errorItems)
            if !result.0 {
                var loadInfoItem: [String: Any] = [:]
                loadInfoItem["ad"] = ["id": "",
                                      "source": "mintegral",
                                      "placement_id": adUnitID]
                loadInfoItem["result"] = ["success": false,
                                          "error": XbAdError.NATIVE_AD_NO_MORE_TRY_ERROR_CODE,
                                          "placement_id": adUnitID,
                                          "msg": XbAdError.NATIVE_AD_MSG_NO_MORE_TRY,
                                          "trigger_code": result.1]
                AdvertConfig.shared.sspLoadCallback?((source: "mintegral", placementId: adUnitID, success: false, error: XbAdError.NATIVE_AD_NO_MORE_TRY_ERROR_CODE , msg: XbAdError.NATIVE_AD_MSG_NO_MORE_TRY, duration: Date().timeIntervalSince1970 - startTime, groupLoadInfo: [loadInfoItem]))
                return
            }
        }
        let cache = MTGAdDownloader()
        cache.cacheCallBack = { (id, isTooFrequently, lastFrequentlyTime, errorCode, msg, placementID, nativeAd) in
            
            if nativeAd != nil {
                print("mintegral--------", nativeAd?.nativeAd?.appDesc)
                self.preloadingMTGAdes[placementID]!.append((nativeAd!, Date().timeIntervalSince1970))
                
                AdvertConfig.shared.sspLoadCallback?((source: "mintegral", placementId: placementID, success: true, error: nil, msg: nil, duration: Date().timeIntervalSince1970 - startTime, groupLoadInfo: []))
                self.mtgError[placementID] = nil
            } else {
                AdvertConfig.shared.sspLoadCallback?((source: "mintegral", placementId: placementID, success: false, error: errorCode, msg: msg, duration: Date().timeIntervalSince1970 - startTime, groupLoadInfo: []))
                
                //                    广告请求的报错记录
                if let errorItems = self.mtgError[placementID] {
                    if let error = errorItems[errorCode] {
                        let tempError = error
                        tempError.count += 1
                        tempError.time = Date().timeIntervalSince1970
                        self.mtgError[placementID]?[errorCode] = tempError
                    } else {
                        let tempError = XbAdErrorItem()
                        tempError.count = 1
                        tempError.time = Date().timeIntervalSince1970
                        self.mtgError[placementID]?[errorCode] = tempError
                    }
                    
                } else {
                    var errorDic: [Int: XbAdErrorItem] = [:]
                    let tempError = XbAdErrorItem()
                    tempError.count = 1
                    tempError.time = Date().timeIntervalSince1970
                    errorDic[errorCode] = tempError
                    self.mtgError[placementID] = errorDic
                }
            }
            
            _ = DelayTimer.delay(AdvertConfig.shared.config?.googleAd.reqIntervalTime ?? 15, task: {
                self.mtgAdDownloaders[adUnitID] = nil
                self.fetchPreloadingMTGAds(adUnitID : adUnitID)
            })
        }
        cache.cacheAd(placementId: adUnitID)
        self.mtgAdDownloaders[adUnitID] = cache
    }
    
}

