//
//  XbAdManager_FB.swift
//  XBADBaseDemo
//
//  Created by 全尼古拉斯 on 2020/3/26.
//  Copyright © 2020 全尼古拉斯. All rights reserved.
//

import Foundation
import FBAudienceNetwork

extension SDKGroupItem {
    var fbNativeAd: FBNativeAd? {
        get {
            return nativeAd as? FBNativeAd
        }
        set {
            nativeAd = newValue
        }
    }
}

extension XbAdError {
    var facebookError: [String: [Int: XbAdErrorItem]] {
        get {
            return adError["facebook"] ?? [:]
        }
        set {
            adError["facebook"] = newValue
        }
    }
}

// MARK: - 缓存FB广告
extension XbAdManager: XbFbAdProtocol {
   
    // 从缓存中取出FB广告
    func getFBNativeAd(xbPlacement: XBPlacementType, placementId : String, price: Double) -> (Bool, FBNativeAd?, SDKGroupItem?) {
        guard let group = preloadingXBAdes[xbPlacement.rawValue], group.count > 0 else {
            return (false, nil, nil)
        }
        var currentItem: SDKGroupItem?
        for (index, item) in group.enumerated() {
            if item.placement == placementId, item.price == price {
                currentItem = item
                preloadingXBAdes[xbPlacement.rawValue]?.remove(at: index)
                dPrint("----XBAD---XB_缓存池状态---消耗---:", xbPlacement.rawValue, preloadingXBAdes[xbPlacement.rawValue]?.count)
                break
            }
        }
        if currentItem != nil && Date().timeIntervalSince1970 - (currentItem?.cacheTime ?? 0) > (currentItem?.cacheValidTime ?? 0) {
            return getFBNativeAd(xbPlacement: xbPlacement, placementId: placementId, price: price)
        }
        return (currentItem?.fbNativeAd != nil, currentItem?.fbNativeAd, currentItem)
    }
    
    // 请求缓存FB广告
    func cacheFBNativeAd(xbPlacement: String, item: SDKGroupItem, duplicate: Int?, frequencyControl: FrequencyControl?, complete: ((Bool, String, SDKGroupItem?, [String: Any])->())?) {
        var tempItem = item
        //            限频操作
        if let frequencyItems = frequencyControl?.facebook, let errorItems = xbAdError.facebookError[tempItem.placement ?? ""] {
            
            let result = checkErrorCode(frequencyItems: frequencyItems, errorDic: errorItems)
            if !result.0 {
                var loadInfoItem: [String: Any] = [:]
                loadInfoItem["ad"] = ["id": "",
                                      "source": tempItem.source ?? "",
                                      "placement_id": tempItem.placement ?? ""]
                loadInfoItem["result"] = ["success": false,
                                          "error": XbAdError.NATIVE_AD_NO_MORE_TRY_ERROR_CODE,
                                          "placement_id": tempItem.placement ?? "",
                                          "msg": XbAdError.NATIVE_AD_MSG_NO_MORE_TRY,
                                          "trigger_code": result.1]
                dPrint("----XBAD---XB_FB_AD保存---过滤---:", xbPlacement, tempItem.toJSON(), loadInfoItem)
                
                complete?(false, xbPlacement, nil, loadInfoItem)
                return
            }
        }
        
        dPrint("----XBAD---XB_FB_AD保存开始---:", xbPlacement, tempItem.toJSON())
        
        fetchFbAd(item: tempItem, duplicate: duplicate ?? 1, complete: { (nativeAd, title, desc, result) in
            
            var success: Bool = nativeAd != nil
            var cacheResult = result
            if duplicate != 1 && self.checkIsDuplicate(title: title, xbPlacement: xbPlacement) {
                success = false
                cacheResult = (XbAdError.NATIVE_AD_REDUNDANT_ERROR_CODE, XbAdError.NATIVE_AD_MSG_REDUNDANT, result.duration)
            }
            
            var loadInfoItem: [String: Any] = [:]
            loadInfoItem["ad"] = ["id": "",
                                  "source": tempItem.source ?? "",
                                  "placement_id": tempItem.placement ?? "",
                                  "title": title ,
                                  "desc": desc]
            loadInfoItem["result"] = ["success": success,
                                      "error": cacheResult.errorCode,
                                      "placement_id": tempItem.placement ?? "",
                                      "msg": cacheResult.msg,
                                      "duration": cacheResult.duration]
            
            if success {
                tempItem.title = title
                tempItem.desc = desc
                tempItem.fbNativeAd = nativeAd
                
                dPrint("----XBAD---XB_FB_AD保存成功---:", xbPlacement, tempItem.toJSON())
                //  缓存 成功，清除改placement下的负面状态code
                self.xbAdError.facebookError[tempItem.placement ?? ""] = nil
            } else {
                
                //                    广告请求的报错记录
                if let errorItems = self.xbAdError.facebookError[tempItem.placement ?? ""] {
                    if let error = errorItems[cacheResult.errorCode] {
                        let tempError = error
                        tempError.count += 1
                        tempError.time = Date().timeIntervalSince1970
                        self.xbAdError.facebookError[tempItem.placement ?? ""]?[cacheResult.errorCode] = tempError
                    } else {
                        let tempError = XbAdErrorItem()
                        tempError.count = 1
                        tempError.time = Date().timeIntervalSince1970
                        self.xbAdError.facebookError[tempItem.placement ?? ""]?[cacheResult.errorCode] = tempError
                    }
                    
                } else {
                    var errorDic: [Int: XbAdErrorItem] = [:]
                    let tempError = XbAdErrorItem()
                    tempError.count = 1
                    tempError.time = Date().timeIntervalSince1970
                    errorDic[cacheResult.errorCode] = tempError
                    self.xbAdError.facebookError[tempItem.placement ?? ""] = errorDic
                }
                
                dPrint("----XBAD---XB_FB_AD保存失败---:", xbPlacement, self.xbAdError.toJSON(), loadInfoItem)
                
            }
            complete?(success ,xbPlacement, tempItem, loadInfoItem)
            
        })
    }
}
