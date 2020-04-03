//
//  DUNativeAdManager.swift
//  TopNews
//
//  Created by xb on 2019/4/12.
//  Copyright © 2019年 xb. All rights reserved.
//

import UIKit
import DUModuleSDK
class DUNativeAdManager: NSObject, checkErrorProtocol  {
    static let shared = DUNativeAdManager()
    
    var isFirstPreloadingDUAdes : Bool = true
    var preloadingDUAdes : [String : [(DUNativeAd, TimeInterval)]] = [:]
    
    var baiduError: [String: [Int: XbAdErrorItem]] = [:]
    
    var duAdDownloaders: [String : DUAdDownloader?] = [:]
}

extension DUNativeAdManager {
    
    func getDUNativeAd(placementId : String) -> (Bool,DUNativeAd?) {
        if preloadingDUAdes[placementId] == nil {
            preloadingDUAdes[placementId] = []
        }
        
        checkTimeout(placementId: placementId)
        var result: (Bool,DUNativeAd?) = (false,nil)
        if !preloadingDUAdes[placementId]!.isEmpty {
            if let tempAd = preloadingDUAdes[placementId]!.first?.0 {
                preloadingDUAdes[placementId]!.removeFirst()
                result = (true,tempAd)
            }
        }
        fetchPreloadingDUAds(placementId : placementId)
        return result
    }
    func checkTimeout(placementId: String) {
        //获取广告之前检查缓存时间超过2小时
        let cacheValidTime = AdvertConfig.shared.config?.baiduAd.cacheValidTime ?? 60 * 60
        preloadingDUAdes[placementId] = preloadingDUAdes[placementId]?.filter{
            return (Date().timeIntervalSince1970 - $1) < cacheValidTime
        }
    }
    
    func fetchPreloadingDUAds(placementId : String) {
        
        if preloadingDUAdes[placementId] == nil {
            preloadingDUAdes[placementId] = []
        }
        let cacheSize = AdvertConfig.shared.config?.baiduAd.cacheSize ?? 3
        while (preloadingDUAdes[placementId]?.count)! >= cacheSize {
            return
        }
        if duAdDownloaders[placementId] != nil {
            return
        }
        let startTime = Date().timeIntervalSince1970
        
        //            限频操作
        if let frequencyItems = AdvertConfig.shared.config?.frequencyControl?.baidu, let errorItems = self.baiduError[placementId] {
            
            let result = self.checkErrorCode(frequencyItems: frequencyItems, errorDic: errorItems)
            if !result.0 {
                var loadInfoItem: [String: Any] = [:]
                loadInfoItem["ad"] = ["id": "",
                                      "source": "baidu",
                                      "placement_id": placementId]
                loadInfoItem["result"] = ["success": false,
                                          "error": XbAdError.NATIVE_AD_NO_MORE_TRY_ERROR_CODE,
                                          "placement_id": placementId,
                                          "msg": XbAdError.NATIVE_AD_MSG_NO_MORE_TRY,
                                          "trigger_code": result.1]
                AdvertConfig.shared.sspLoadCallback?((source: "baidu", placementId: placementId, success: false, error: XbAdError.NATIVE_AD_NO_MORE_TRY_ERROR_CODE , msg: XbAdError.NATIVE_AD_MSG_NO_MORE_TRY, duration: Date().timeIntervalSince1970 - startTime, groupLoadInfo: [loadInfoItem]))
                return
            }
        }
        let cache = DUAdDownloader()
        cache.cacheCallBack = { (id, isTooFrequently, lastFrequentlyTime, errorCode, msg, placementID, nativeAd) in
            
            if nativeAd != nil {
                
                self.preloadingDUAdes[placementID]!.append((nativeAd!, Date().timeIntervalSince1970))
                
                AdvertConfig.shared.sspLoadCallback?((source: "baidu", placementId: placementID, success: true, error: nil, msg: nil, duration: Date().timeIntervalSince1970 - startTime, groupLoadInfo: []))
                self.baiduError[placementID] = nil
            } else {
                AdvertConfig.shared.sspLoadCallback?((source: "baidu", placementId: placementID, success: false, error: errorCode ?? 1, msg: msg, duration: Date().timeIntervalSince1970 - startTime, groupLoadInfo: []))
                
                //                    广告请求的报错记录
                if let errorItems = self.baiduError[placementID] {
                    if let error = errorItems[errorCode] {
                        let tempError = error
                        tempError.count += 1
                        tempError.time = Date().timeIntervalSince1970
                        self.baiduError[placementID]?[errorCode] = tempError
                    } else {
                        let tempError = XbAdErrorItem()
                        tempError.count = 1
                        tempError.time = Date().timeIntervalSince1970
                        self.baiduError[placementID]?[errorCode] = tempError
                    }
                    
                } else {
                    var errorDic: [Int: XbAdErrorItem] = [:]
                    let tempError = XbAdErrorItem()
                    tempError.count = 1
                    tempError.time = Date().timeIntervalSince1970
                    errorDic[errorCode] = tempError
                    self.baiduError[placementID] = errorDic
                }
            }
            _ = DelayTimer.delay(AdvertConfig.shared.config?.facebookAd.reqIntervalTime ?? 15, task: {
                self.duAdDownloaders[placementId] = nil
                self.fetchPreloadingDUAds(placementId: placementId)
            })
        }
        cache.cacheAd(placementId: placementId)
        self.duAdDownloaders[placementId] = cache
    }
}

