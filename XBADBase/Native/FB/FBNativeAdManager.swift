//
//  FBNativeAdManager.swift
//  TopNews
//  非聚合缓存
//  Created by xb on 2018/5/3.
//  Copyright © 2018年 xb. All rights reserved.
//

import UIKit
import FBAudienceNetwork
protocol checkErrorProtocol: class {
    func checkErrorCode(frequencyItems: [FrequencyControlItem], errorDic: [Int: XbAdErrorItem]) -> (Bool, Int)
}
extension checkErrorProtocol {
    // 检查error code是否达到最大限度
    func checkErrorCode(frequencyItems: [FrequencyControlItem], errorDic: [Int: XbAdErrorItem]) -> (Bool, Int) {
        var tempErrorDic = errorDic
        // 是否可以继续请求广告
        var isContinue: Bool = true
        var triggerCode: Int = 0
        for item in frequencyItems {
            if let error = tempErrorDic[item.code ?? 0] {
                if Date().timeIntervalSince1970 - error.time > item.wait {
                    tempErrorDic[item.code ?? 0] = nil
                } else {
                    isContinue = false
                    triggerCode = item.code ?? 0
                    break
                }
            }
        }
        return (isContinue, triggerCode)
    }
}

class FBNativeAdManager: NSObject, checkErrorProtocol {
    static let shared = FBNativeAdManager()
    
    var isFirstPreloadingFBAdes : Bool = true
    var preloadingFBAdes : [String : [(FBNativeAd, TimeInterval)]] = [:]
    
    var facebookError: [String: [Int: XbAdErrorItem]] = [:]
    var fbAdDownloaders: [String : FBAdDownloader?] = [:]
}

extension FBNativeAdManager {
    
    func getFBNativeAd(placementId : String) -> (Bool,FBNativeAd?) {
        if preloadingFBAdes[placementId] == nil {
            preloadingFBAdes[placementId] = []
        }
        checkTimeout(placementId: placementId)
        var result: (Bool,FBNativeAd?) = (false,nil)
        if !preloadingFBAdes[placementId]!.isEmpty {
            if let tempAd = preloadingFBAdes[placementId]!.first?.0, tempAd.isAdValid {
                preloadingFBAdes[placementId]!.removeFirst()
                result = (true,tempAd)
            }
        }
        fetchPreloadingFBAds(placementId : placementId)
        return result
    }
    
    func checkTimeout(placementId: String) {
        //获取广告之前检查缓存时间超过2小时
        let cacheValidTime = AdvertConfig.shared.config?.facebookAd.cacheValidTime ?? 60 * 60
        preloadingFBAdes[placementId] = preloadingFBAdes[placementId]?.filter{
            return (Date().timeIntervalSince1970 - $1) < cacheValidTime
        }
    }
    func fetchPreloadingFBAds(placementId : String) {
        
        if preloadingFBAdes[placementId] == nil {
            preloadingFBAdes[placementId] = []
        }
        let cacheSize = AdvertConfig.shared.config?.facebookAd.cacheSize ?? 3
        while (preloadingFBAdes[placementId]?.count)! >= cacheSize {
            return
        }
        if self.fbAdDownloaders[placementId] != nil {
            return
        }
        let startTime = Date().timeIntervalSince1970
        //   限频操作
        if let frequencyItems =
            AdvertConfig.shared.config?.frequencyControl?.facebook, let errorItems = self.facebookError[placementId] {
            
            let result = self.checkErrorCode(frequencyItems: frequencyItems, errorDic: errorItems)
            if !result.0 {
                var loadInfoItem: [String: Any] = [:]
                loadInfoItem["ad"] = ["id": "",
                                      "source": "facebook",
                                      "placement_id": placementId]
                loadInfoItem["result"] = ["success": false,
                                          "error": XbAdError.NATIVE_AD_NO_MORE_TRY_ERROR_CODE,
                                          "placement_id": placementId,
                                          "msg": XbAdError.NATIVE_AD_MSG_NO_MORE_TRY,
                                          "trigger_code": result.1]
                AdvertConfig.shared.sspLoadCallback?((source: "facebook", placementId: placementId, success: false, error: XbAdError.NATIVE_AD_NO_MORE_TRY_ERROR_CODE , msg: XbAdError.NATIVE_AD_MSG_NO_MORE_TRY, duration: Date().timeIntervalSince1970 - startTime, groupLoadInfo: [loadInfoItem]))
                return
            }
        }
        
        let cache = FBAdDownloader()
        cache.cacheCallBack = { (id, isTooFrequently, lastFrequentlyTime, errorCode, msg, placementID, nativeAd) in
            
            if nativeAd != nil {
                
                self.preloadingFBAdes[placementID]!.append((nativeAd!, Date().timeIntervalSince1970))
                
                AdvertConfig.shared.sspLoadCallback?((source: "facebook", placementId: placementID, success: true, error: nil, msg: nil, duration: Date().timeIntervalSince1970 - startTime, groupLoadInfo: []))
                self.facebookError[placementID] = nil
            } else {
                AdvertConfig.shared.sspLoadCallback?((source: "facebook", placementId: placementID, success: false, error: errorCode , msg: msg, duration: Date().timeIntervalSince1970 - startTime, groupLoadInfo: []))
                //                    广告请求的报错记录
                if let errorItems = self.facebookError[placementID] {
                    if let error = errorItems[errorCode] {
                        let tempError = error
                        tempError.count += 1
                        tempError.time = Date().timeIntervalSince1970
                        self.facebookError[placementID]?[errorCode] = tempError
                    } else {
                        let tempError = XbAdErrorItem()
                        tempError.count = 1
                        tempError.time = Date().timeIntervalSince1970
                        self.facebookError[placementID]?[errorCode] = tempError
                    }
                    
                } else {
                    var errorDic: [Int: XbAdErrorItem] = [:]
                    let tempError = XbAdErrorItem()
                    tempError.count = 1
                    tempError.time = Date().timeIntervalSince1970
                    errorDic[errorCode] = tempError
                    self.facebookError[placementID] = errorDic
                }
            }
            
            _ = DelayTimer.delay(AdvertConfig.shared.config?.facebookAd.reqIntervalTime ?? 15, task: {
                self.fbAdDownloaders[placementId] = nil
                self.fetchPreloadingFBAds(placementId: placementId)
            })
            
            
        }
        cache.cacheAd(placementId: placementId)
        self.fbAdDownloaders[placementId] = cache
    }
}
