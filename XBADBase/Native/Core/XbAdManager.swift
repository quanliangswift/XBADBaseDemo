//
//  XbAdManager.swift
//  TopNews
//
//  Created by xb on 2019/3/21.
//  Copyright © 2019年 xb. All rights reserved.
//

import UIKit
//import FBAudienceNetwork
//import GoogleMobileAds
//import DUModuleSDK

typealias cacheResult = (errorCode: Int, msg: String, duration: Double)

protocol NativeAdDelegate: class {
    func onCacheAd(xbPlacement: String, item: SDKGroupItem, duplicate: Int?, frequencyControl: FrequencyControl?, complete: ((Bool, String, SDKGroupItem?, [String: Any])->())?)
}

class XbAdManager: NSObject, SSPAdvertLoadLogProtocol, SSPAdvertExpireLogProtocol {
    
    
    static let shared = XbAdManager()
    
    var preloadingXBAdes: [String: [SDKGroupItem]] = [:]
    //  各个xb_placement正在缓存的数量
    var preloadingXBAdCount: [String: Int] = [:]

    var nativeAdDownloaders: [Int64 : NativeAdDownloaderDelegate] = [:]
    var xbAdError: XbAdError = XbAdError.init()
    
    // 目前广告缓存工厂的订单数
    var currentOrderNum: [String: Int] = [:]
        
    
    var nativeAdDelegates: [String: NativeAdDelegate] = [:]

    func registerAdDelegate(key: String, delegate: NativeAdDelegate) {
        nativeAdDelegates[key] = delegate
    }
    
    func unregisterAdDelegate(key: String, delegate: NativeAdDelegate) {
        nativeAdDelegates[key] = nil
    }
    
    /// 获取请求中缓存的配置
    ///
    func getXbAd(by integration: XbSDKIntegration, slots: Int) -> [SDKGroupItem] {
        //  如果广告缓存格子不满，则补充
        var items = preloadingXBAdes[integration.xbPlacement!] ?? []
        var toItems = [SDKGroupItem]()
        if slots <= 0 {return []}
        if items.count >= slots {
            toItems = Array(items[0..<slots])
        } else {
            toItems = items
        }
        return toItems
    }
    
    func removeAllOldAd() {
        preloadingXBAdes.removeAll()
        preloadingXBAdCount.removeAll()
    }
    func removeCacheXbAd(by integration: XbSDKIntegration) {
        guard let xbPlacement = integration.xbPlacement else {return}
        preloadingXBAdCount[xbPlacement] = 0
        preloadingXBAdes[xbPlacement]?.removeAll()
    }
    var totalStart = 0
    var totalEnd = 0
    
    /// 根据聚合信息开始缓存广告
    /// 串行缓存填格子
    func startCacheXbAd(by integration: XbSDKIntegration, finished: (() -> ())?) {
        guard let xbPlacement = integration.xbPlacement else {return}
        //  检查过期
        checkTimeout(by: xbPlacement)
        // 工厂订单数加上当前新增的订单数
        let count = preloadingXBAdes[xbPlacement]?.count ?? 0
        let cacheSize = integration.cacheSize ?? 0
        
        currentOrderNum[xbPlacement] = (currentOrderNum[xbPlacement] ?? 0) + cacheSize - count
        
        startConsumeOrder(by: integration, finished: finished)
    }
    // 开始消耗缓存广告的订单
    func startConsumeOrder(by integration: XbSDKIntegration, finished: (() -> ())?) {
        guard let xbPlacement = integration.xbPlacement else {return}
        
        let count = preloadingXBAdes[xbPlacement]?.count ?? 0
        
        // 当前订单数为0，结束
        if  currentOrderNum[xbPlacement] == 0 {
            dPrint("----XBAD---XB 订单消耗完---\(xbPlacement), 缓存数: \(count)")
            finished?()
            return
        }
        
        // 如果缓存池已满，就结束，并将订单数置为0
        let cacheSize = integration.cacheSize ?? 0
        if count >= cacheSize {
            dPrint("----XBAD---XB 缓存池满---\(xbPlacement) , 订单数: \(currentOrderNum[xbPlacement])")
            currentOrderNum[xbPlacement] = 0
            finished?()
            return
        }
        
        // 尝试去启动工厂，缓存ad
        let startPreloadingCount = preloadingXBAdCount[xbPlacement] ?? 0
        // 如果当前xbPlacement正在缓存的数量不是0，就说明现在正在缓存，所以不需要再次触发
        if startPreloadingCount != 0 {
            return
        }
        // 开始缓存，订单数-1
        currentOrderNum[xbPlacement] = (currentOrderNum[xbPlacement] ?? 0) - 1
        
        // 当前没有正在缓存该xbplacement
        preloadingXBAdCount[xbPlacement] = 1
        totalStart += 1
        let startTime = Date().timeIntervalSince1970
        // 开始缓存逻辑
        self.setAdCache(xbPlacement: xbPlacement, group: integration.sdkGroup ?? [], frequencyControl: integration.frequencyControl) { (success, xbPlacement, item, group, groupLoadInfo) in
            self.preloadingXBAdCount[xbPlacement] = 0
            self.totalEnd += 1
            let useTime = Date().timeIntervalSince1970 - startTime
            dPrint("----XBAD---XB结束---", self.totalStart, self.totalEnd, useTime)
            self.logSSPAdvertLoad(source: "sharp", placementId: xbPlacement, success: success, error: nil, msg: nil, duration: useTime, groupLoadInfo: groupLoadInfo)
            
            if success {
                // 请求成功，加入缓存池， 并请求下一个格子
                self.addXBAd(xbPlacement: xbPlacement, item: item!)
            }
            self.startConsumeOrder(by: integration, finished: finished)
        }
    }
    // 记录placement上次load的时间，用以作为判断是否进入请求限频逻辑
    func recordLastLoadAdTime(xbPlacement: String, placement: String) {
        if xbPlacement == "" || placement == "" {
            return
        }
        for (index, native) in XbSDKIntegrationManager.shared.xbAdIntegration.nativeAds.enumerated() {
            if (native.xbPlacement ?? "") == xbPlacement {
                for (key, value) in (native.sdkGroup ?? []).enumerated() {
                    if value.placement == placement {
                        XbSDKIntegrationManager.shared.xbAdIntegration.nativeAds[index].sdkGroup?[key].lastLoadAdTime = Date().timeIntervalSince1970
                    }
                }
            }
        }
    }
    
    // 判断拿到的结果是不是都是限频导致的失败
    func isAllNoMoreTry(groupLoadInfo: [[String: Any]]) -> Bool {
        for info in groupLoadInfo {
            if let result = info["result"] as? [String: Any],
                result["error"] as? Int != XbAdError.NATIVE_AD_NO_MORE_TRY_ERROR_CODE {
                return false
            }
        }
        return true
    }
    
    /// 预缓存的XBAd
    ///
    func addXBAd(xbPlacement: String, item: SDKGroupItem) {
        var tempItem = item
        tempItem.cacheTime = Date().timeIntervalSince1970
        if let _ = preloadingXBAdes[xbPlacement] {
            preloadingXBAdes[xbPlacement]?.append(tempItem)
        } else {
            preloadingXBAdes[xbPlacement] = [tempItem]
        }
        // 按照价格顺序排序缓存广告
        let items = preloadingXBAdes[xbPlacement]?.sorted(by: { (item1, item2) -> Bool in
            return item1.price > item2.price
        })
        preloadingXBAdes[xbPlacement] = items
        dPrint("----XBAD---XB_缓存池状态---保存---:", xbPlacement, preloadingXBAdes[xbPlacement]?.count ?? 0)
        
    }
    
    /// 根据价格排序缓存广告的顺序，开始进行缓存
    ///
    func setAdCache(xbPlacement: String, group: [SDKGroupItem], frequencyControl: FrequencyControl?, complete: ((Bool, String, SDKGroupItem?, [SDKGroupItem], [[String: Any]])->())?) {
        let startIndex = 0
        // 串行请求广告
        cacheNextAd(xbPlacement: xbPlacement, index: startIndex, group: group, groupLoadInfo: [], frequencyControl: frequencyControl, complete: complete)
    }
}
//MARK: -串行缓存广告
extension XbAdManager {
    /// 获取需要缓存的目标广告，开始缓存
    ///
    func cacheNextAd(xbPlacement: String, index: Int, group: [SDKGroupItem], groupLoadInfo: [[String: Any]], duplicate: Int? = 1, frequencyControl: FrequencyControl?, complete: ((Bool, String, SDKGroupItem?, [SDKGroupItem], [[String: Any]])->())?) {
        if index >= group.count {
            complete?(false, xbPlacement, nil, group, groupLoadInfo)
            return
        }
        
        var tempInfo = groupLoadInfo
        let item = group[index]
        
        // 判断placement是否频繁触发load
        if Date().timeIntervalSince1970 - item.lastLoadAdTime < item.reqIntervalTime {
            var loadInfoItem: [String: Any] = [:]
            loadInfoItem["ad"] = ["id": "",
                                  "source": item.source ?? "",
                                  "placement_id": item.placement ?? ""]
            loadInfoItem["result"] = ["success": false,
                                      "error": XbAdError.NATIVE_AD_REQ_INTERVAL_TIME_ERROR_CODE,
                                      "placement_id": item.placement ?? "",
                                      "msg": XbAdError.NATIVE_AD_REQ_INTERVAL_TIME]
            dPrint("----XBAD---XB_AD_xbplacement保存---过滤---:", xbPlacement, item.toJSON(), loadInfoItem)
            tempInfo.append(loadInfoItem)
            self.cacheNextAd(xbPlacement: xbPlacement, index: index + 1, group: group, groupLoadInfo: tempInfo, duplicate: duplicate, frequencyControl: frequencyControl, complete: complete)
            return
        }
        if let delegate = nativeAdDelegates[item.source ?? ""] {
//            delegate.onCacheAd
        }
//        switch item.source ?? "" {
//        case ADType.admob.rawValue:
//
//            cacheGoogleNativeAd(xbPlacement: xbPlacement, item: item, duplicate: duplicate, frequencyControl: frequencyControl) { (success, xbPlacement, item, loadInfo) in
//                // 请求结束，记录时间
//                // 不是限频导致的请求失败，记录时间
//                if !(!success && (loadInfo["result"] as? [String: Any])?["error"] as? Int == XbAdError.NATIVE_AD_NO_MORE_TRY_ERROR_CODE) {
//                    self.recordLastLoadAdTime(xbPlacement: xbPlacement, placement: item?.placement ?? "")
//                }
//
//                tempInfo.append(loadInfo)
//                if success {
//                    var tempItem = item
//                    tempItem?.groupLoadInfo = tempInfo
//                    complete?(true, xbPlacement, tempItem, group, tempInfo)
//                } else {
//                    self.cacheNextAd(xbPlacement: xbPlacement, index: index + 1, group: group, groupLoadInfo: tempInfo, duplicate: duplicate, frequencyControl: frequencyControl, complete: complete)
//                }
//            }
//            break
//        case ADType.facebook.rawValue:
//            cacheFBNativeAd(xbPlacement: xbPlacement, item: item, duplicate: duplicate, frequencyControl: frequencyControl) { (success, xbPlacement, item, loadInfo) in
//                // 请求结束，记录时间
//                // 不是限频导致的请求失败，记录时间
//                if !(!success && (loadInfo["result"] as? [String: Any])?["error"] as? Int == XbAdError.NATIVE_AD_NO_MORE_TRY_ERROR_CODE) {
//                    self.recordLastLoadAdTime(xbPlacement: xbPlacement, placement: item?.placement ?? "")
//                }
//                tempInfo.append(loadInfo)
//                if success {
//                    var tempItem = item
//                    tempItem?.groupLoadInfo = tempInfo
//                    complete?(true, xbPlacement, tempItem, group, tempInfo)
//                } else {
//                    self.cacheNextAd(xbPlacement: xbPlacement, index: index + 1, group: group, groupLoadInfo: tempInfo, duplicate: duplicate, frequencyControl: frequencyControl, complete: complete)
//                }
//            }
//            break
//        case ADType.baidu.rawValue:
//            cacheDUNativeAd(xbPlacement: xbPlacement, item: item, duplicate: duplicate, frequencyControl: frequencyControl) { (success, xbPlacement, item, loadInfo) in
//                // 请求结束，记录时间
//                // 不是限频导致的请求失败，记录时间
//                if !(!success && (loadInfo["result"] as? [String: Any])?["error"] as? Int == XbAdError.NATIVE_AD_NO_MORE_TRY_ERROR_CODE) {
//                    self.recordLastLoadAdTime(xbPlacement: xbPlacement, placement: item?.placement ?? "")
//                }
//                tempInfo.append(loadInfo)
//                if success {
//                    var tempItem = item
//                    tempItem?.groupLoadInfo = tempInfo
//                    complete?(true, xbPlacement, tempItem, group, tempInfo)
//                } else {
//                    self.cacheNextAd(xbPlacement: xbPlacement, index: index + 1, group: group, groupLoadInfo: tempInfo, duplicate: duplicate, frequencyControl: frequencyControl, complete: complete)
//                }
//            }
//            break
//        case ADType.appnext.rawValue:
//            cacheAppnextNativeAd(xbPlacement: xbPlacement, item: item, duplicate: duplicate, frequencyControl: frequencyControl) { (success, xbPlacement, item, loadInfo) in
//                // 请求结束，记录时间
//                // 不是限频导致的请求失败，记录时间
//                if !(!success && (loadInfo["result"] as? [String: Any])?["error"] as? Int == XbAdError.NATIVE_AD_NO_MORE_TRY_ERROR_CODE) {
//                    self.recordLastLoadAdTime(xbPlacement: xbPlacement, placement: item?.placement ?? "")
//                }
//                tempInfo.append(loadInfo)
//                if success {
//                    var tempItem = item
//                    tempItem?.groupLoadInfo = tempInfo
//                    complete?(true, xbPlacement, tempItem, group, tempInfo)
//                } else {
//                    self.cacheNextAd(xbPlacement: xbPlacement, index: index + 1, group: group, groupLoadInfo: tempInfo, duplicate: duplicate, frequencyControl: frequencyControl, complete: complete)
//                }
//            }
//            break
//        case ADType.mintegral.rawValue:
//            cacheMTGNativeAd(xbPlacement: xbPlacement, item: item, duplicate: duplicate, frequencyControl: frequencyControl) { (success, xbPlacement, item, loadInfo) in
//                // 请求结束，记录时间
//                // 不是限频导致的请求失败，记录时间
//                if !(!success && (loadInfo["result"] as? [String: Any])?["error"] as? Int == XbAdError.NATIVE_AD_NO_MORE_TRY_ERROR_CODE) {
//                    self.recordLastLoadAdTime(xbPlacement: xbPlacement, placement: item?.placement ?? "")
//                }
//                tempInfo.append(loadInfo)
//                if success {
//                    var tempItem = item
//                    tempItem?.groupLoadInfo = tempInfo
//                    complete?(true, xbPlacement, tempItem, group, tempInfo)
//                } else {
//                    self.cacheNextAd(xbPlacement: xbPlacement, index: index + 1, group: group, groupLoadInfo: tempInfo, duplicate: duplicate, frequencyControl: frequencyControl, complete: complete)
//                }
//            }
//            break
//        default:
//            complete?(false, xbPlacement, nil, group, [])
//            break
//        }
    }
    
}

extension XbAdManager {
    // 检查error code是否达到最大限度
    func checkErrorCode(frequencyItems: [FrequencyControlItem], errorDic: [Int: XbAdErrorItem]) -> (Bool, Int) {
        var tempErrorDic = errorDic
        // 是否可以继续请求广告
        var isContinue: Bool = true
        var errorCode: Int = 0
        for item in frequencyItems {
            if let error = tempErrorDic[item.code ?? 0] {
                if Date().timeIntervalSince1970 - error.time > item.wait {
                    tempErrorDic[item.code ?? 0] = nil
                } else {
                    isContinue = false
                    errorCode = item.code ?? 0
                    break
                }
            }
        }
        return (isContinue, errorCode)
    }
    //  检查统一xb广告位是否有重复广告
    func checkIsDuplicate(title: String, xbPlacement: String) -> Bool {
        let items = preloadingXBAdes[xbPlacement] ?? []
        for item in items {
            if item.title == title {
                return true
            }
        }
        return false
    }
    
    //  检查过期
    func checkTimeout(by xbPlacement: String) {
        guard let _ = preloadingXBAdes[xbPlacement] else {
            return
        }
        preloadingXBAdes[xbPlacement] = preloadingXBAdes[xbPlacement]?.filter({ (item) -> Bool in
            if Date().timeIntervalSince1970 - (item.cacheTime ?? 0) < (item.cacheValidTime ?? 0) {
                return true
            } else {
                // 检查到过期，上报
                let ad: [String: Any] = ["source": "sharp",
                                         "id": "",
                                         "placement_id": xbPlacement,
                                         "info": item.groupLoadInfo.last?["ad"] as? [String : Any]]
                self.logSSPAdvertExpire(ad: ad)
                return false
            }
        })
    }
}
//
//// MARK: - 缓存FB广告
//extension XbAdManager {
//    // 从缓存中取出FB广告
//    func getFBNativeAd(xbPlacement: XBPlacementType, placementId : String, price: Double) -> (Bool, FBNativeAd?, SDKGroupItem?) {
//        guard let group = preloadingXBAdes[xbPlacement.rawValue], group.count > 0 else {
//            return (false, nil, nil)
//        }
//        var currentItem: SDKGroupItem?
//        for (index, item) in group.enumerated() {
//            if item.placement == placementId, item.price == price {
//                currentItem = item
//                preloadingXBAdes[xbPlacement.rawValue]?.remove(at: index)
//                dPrint("----XBAD---XB_缓存池状态---消耗---:", xbPlacement.rawValue, preloadingXBAdes[xbPlacement.rawValue]?.count)
//                break
//            }
//        }
//        if currentItem != nil && Date().timeIntervalSince1970 - (currentItem?.cacheTime ?? 0) > (currentItem?.cacheValidTime ?? 0) {
//            return getFBNativeAd(xbPlacement: xbPlacement, placementId: placementId, price: price)
//        }
//        return (currentItem?.fbNativeAd != nil, currentItem?.fbNativeAd, currentItem)
//    }
//
//    // 请求缓存FB广告
//    func cacheFBNativeAd(xbPlacement: String, item: SDKGroupItem, duplicate: Int?, frequencyControl: FrequencyControl?, complete: ((Bool, String, SDKGroupItem?, [String: Any])->())?) {
//        var tempItem = item
//        //            限频操作
//        if let frequencyItems = frequencyControl?.facebook, let errorItems = xbAdError.facebookError[tempItem.placement ?? ""] {
//
//            let result = checkErrorCode(frequencyItems: frequencyItems, errorDic: errorItems)
//            if !result.0 {
//                var loadInfoItem: [String: Any] = [:]
//                loadInfoItem["ad"] = ["id": "",
//                                      "source": tempItem.source ?? "",
//                                      "placement_id": tempItem.placement ?? ""]
//                loadInfoItem["result"] = ["success": false,
//                                          "error": XbAdError.NATIVE_AD_NO_MORE_TRY_ERROR_CODE,
//                                          "placement_id": tempItem.placement ?? "",
//                                          "msg": XbAdError.NATIVE_AD_MSG_NO_MORE_TRY,
//                                          "trigger_code": result.1]
//                dPrint("----XBAD---XB_FB_AD保存---过滤---:", xbPlacement, tempItem.toJSON(), loadInfoItem)
//
//                complete?(false, xbPlacement, nil, loadInfoItem)
//                return
//            }
//        }
//
//        dPrint("----XBAD---XB_FB_AD保存开始---:", xbPlacement, tempItem.toJSON())
//
//        fetchFbAd(item: tempItem, duplicate: duplicate ?? 1, complete: { (nativeAd, title, desc, result) in
//
//            var success: Bool = nativeAd != nil
//            var cacheResult = result
//            if duplicate != 1 && self.checkIsDuplicate(title: title, xbPlacement: xbPlacement) {
//                success = false
//                cacheResult = (XbAdError.NATIVE_AD_REDUNDANT_ERROR_CODE, XbAdError.NATIVE_AD_MSG_REDUNDANT, result.duration)
//            }
//
//            var loadInfoItem: [String: Any] = [:]
//            loadInfoItem["ad"] = ["id": "",
//                                  "source": tempItem.source ?? "",
//                                  "placement_id": tempItem.placement ?? "",
//                                  "title": title ,
//                                  "desc": desc]
//            loadInfoItem["result"] = ["success": success,
//                                      "error": cacheResult.errorCode,
//                                      "placement_id": tempItem.placement ?? "",
//                                      "msg": cacheResult.msg,
//                                      "duration": cacheResult.duration]
//
//            if success {
//                tempItem.title = title
//                tempItem.desc = desc
//                tempItem.fbNativeAd = nativeAd
//
//                dPrint("----XBAD---XB_FB_AD保存成功---:", xbPlacement, tempItem.toJSON())
//                //  缓存 成功，清除改placement下的负面状态code
//                self.xbAdError.facebookError[tempItem.placement ?? ""] = nil
//            } else {
//
//                //                    广告请求的报错记录
//                if let errorItems = self.xbAdError.facebookError[tempItem.placement ?? ""] {
//                    if let error = errorItems[cacheResult.errorCode] {
//                        let tempError = error
//                        tempError.count += 1
//                        tempError.time = Date().timeIntervalSince1970
//                        self.xbAdError.facebookError[tempItem.placement ?? ""]?[cacheResult.errorCode] = tempError
//                    } else {
//                        let tempError = XbAdErrorItem()
//                        tempError.count = 1
//                        tempError.time = Date().timeIntervalSince1970
//                        self.xbAdError.facebookError[tempItem.placement ?? ""]?[cacheResult.errorCode] = tempError
//                    }
//
//                } else {
//                    var errorDic: [Int: XbAdErrorItem] = [:]
//                    let tempError = XbAdErrorItem()
//                    tempError.count = 1
//                    tempError.time = Date().timeIntervalSince1970
//                    errorDic[cacheResult.errorCode] = tempError
//                    self.xbAdError.facebookError[tempItem.placement ?? ""] = errorDic
//                }
//
//                dPrint("----XBAD---XB_FB_AD保存失败---:", xbPlacement, self.xbAdError.toJSON(), loadInfoItem)
//
//            }
//            complete?(success ,xbPlacement, tempItem, loadInfoItem)
//
//        })
//    }
//}
//
//// MARK: - 缓存Google广告
//extension XbAdManager {
//    // 从缓存中取出Google广告
//    func getGoogleNativeAd(xbPlacement: XBPlacementType, placementId : String, price: Double) -> (Bool, GADUnifiedNativeAd?, SDKGroupItem?) {
//        guard let group = preloadingXBAdes[xbPlacement.rawValue], group.count > 0 else {
//            return (false, nil, nil)
//        }
//        var currentItem: SDKGroupItem?
//        for (index, item) in group.enumerated() {
//            if item.placement == placementId, item.price == price {
//                currentItem = item
//                preloadingXBAdes[xbPlacement.rawValue]?.remove(at: index)
//                dPrint("----XBAD---XB_缓存池状态---消耗---:", xbPlacement.rawValue, preloadingXBAdes[xbPlacement.rawValue]?.count)
//                break
//            }
//        }
//        if currentItem != nil && Date().timeIntervalSince1970 - (currentItem?.cacheTime ?? 0) > (currentItem?.cacheValidTime ?? 0) {
//            return getGoogleNativeAd(xbPlacement: xbPlacement, placementId: placementId, price: price)
//        }
//        return (currentItem?.googleNativeAd != nil, currentItem?.googleNativeAd, currentItem)
//    }
//    // 请求缓存Google广告
//    func cacheGoogleNativeAd(xbPlacement: String, item: SDKGroupItem, duplicate: Int?, frequencyControl: FrequencyControl?, complete: ((Bool, String, SDKGroupItem?, [String: Any])->())?) {
//        var tempItem = item
//        //            限频操作
//        if let frequencyItems = frequencyControl?.admob, let errorItems = xbAdError.admobError[tempItem.placement ?? ""] {
//            let result = checkErrorCode(frequencyItems: frequencyItems, errorDic: errorItems)
//            if !result.0 {
//                var loadInfoItem: [String: Any] = [:]
//                loadInfoItem["ad"] = ["id": "",
//                                      "source": tempItem.source,
//                                      "placement_id": tempItem.placement]
//                loadInfoItem["result"] = ["success": false,
//                                          "error": XbAdError.NATIVE_AD_NO_MORE_TRY_ERROR_CODE,
//                                          "placement_id": tempItem.placement,
//                                          "msg": XbAdError.NATIVE_AD_MSG_NO_MORE_TRY,
//                                          "trigger_code": result.1]
//                dPrint("----XBAD---XB_Google_AD保存---过滤---:", xbPlacement, tempItem.toJSON(), loadInfoItem)
//
//                complete?(false, xbPlacement, tempItem, loadInfoItem)
//                return
//            }
//        }
//
//        dPrint("----XBAD---XB_Google_AD保存开始---:", xbPlacement, tempItem.toJSON())
//        fetchGoogleAd(item: tempItem, duplicate: duplicate ?? 1, complete: { (nativeAd, title, desc, result) in
//            var success: Bool = nativeAd != nil
//            var cacheResult = result
//            if duplicate != 1 && self.checkIsDuplicate(title: title, xbPlacement: xbPlacement) {
//                success = false
//                cacheResult = (XbAdError.NATIVE_AD_REDUNDANT_ERROR_CODE, XbAdError.NATIVE_AD_MSG_REDUNDANT, result.duration)
//            }
//
//
//            var loadInfoItem: [String: Any] = [:]
//            loadInfoItem["ad"] = ["id": "",
//                                  "source": tempItem.source ?? "",
//                                  "placement_id": tempItem.placement ?? "",
//                                  "title": title,
//                                  "desc": desc]
//            loadInfoItem["result"] = ["success": success,
//                                      "error": cacheResult.errorCode,
//                                      "placement_id": tempItem.placement ?? "",
//                                      "msg": cacheResult.msg,
//                                      "duration": cacheResult.duration]
//            if success {
//                tempItem.title = title
//                tempItem.desc = desc
//                tempItem.googleNativeAd = nativeAd
//
//                dPrint("----XBAD---XB_Google_AD保存成功---:", xbPlacement, tempItem.toJSON())
//                //  缓存 成功，清除改placement下的负面状态code
//                self.xbAdError.admobError[tempItem.placement ?? ""] = nil
//            } else {
//                //                    广告请求的报错记录
//                if let errorItems = self.xbAdError.admobError[tempItem.placement ?? ""] {
//                    if let error = errorItems[cacheResult.errorCode] {
//                        let tempError = error
//                        tempError.count += 1
//                        tempError.time = Date().timeIntervalSince1970
//                        self.xbAdError.admobError[tempItem.placement ?? ""]?[cacheResult.errorCode] = tempError
//                    } else {
//                        let tempError = XbAdErrorItem()
//                        tempError.count = 1
//                        tempError.time = Date().timeIntervalSince1970
//                        self.xbAdError.admobError[tempItem.placement ?? ""]?[cacheResult.errorCode] = tempError
//                    }
//
//                } else {
//                    var errorDic: [Int: XbAdErrorItem] = [:]
//
//                    let tempError = XbAdErrorItem()
//                    tempError.count = 1
//                    tempError.time = Date().timeIntervalSince1970
//                    errorDic[cacheResult.errorCode] = tempError
//                    self.xbAdError.admobError[tempItem.placement ?? ""] = errorDic
//                }
//
//
//                dPrint("----XBAD---XB_Google_AD保存失败---:", xbPlacement, self.xbAdError.toJSON(), loadInfoItem)
//
//            }
//            complete?(success ,xbPlacement, tempItem, loadInfoItem)
//
//        })
//    }
//}
//
//
//// MARK: - 缓存BaiDu广告
//extension XbAdManager {
//    // 从缓存中取出BaiDu广告
//    func getDUNativeAd(xbPlacement: XBPlacementType, placementId : String, price: Double) -> (Bool, DUNativeAd?, SDKGroupItem?) {
//        guard let group = preloadingXBAdes[xbPlacement.rawValue], group.count > 0 else {
//            return (false, nil, nil)
//        }
//        var currentItem: SDKGroupItem?
//        for (index, item) in group.enumerated() {
//            if item.placement == placementId, item.price == price {
//                currentItem = item
//                preloadingXBAdes[xbPlacement.rawValue]?.remove(at: index)
//                dPrint("----XBAD---XB_缓存池状态---消耗---:", xbPlacement.rawValue, preloadingXBAdes[xbPlacement.rawValue]?.count)
//                break
//            }
//        }
//        if currentItem != nil && Date().timeIntervalSince1970 - (currentItem?.cacheTime ?? 0) > (currentItem?.cacheValidTime ?? 0) {
//            return getDUNativeAd(xbPlacement: xbPlacement, placementId: placementId, price: price)
//        }
//        return (currentItem?.duNativeAd != nil, currentItem?.duNativeAd, currentItem)
//    }
//
//    // 请求缓存BaiDu广告
//    func cacheDUNativeAd(xbPlacement: String, item: SDKGroupItem, duplicate: Int?, frequencyControl: FrequencyControl?, complete: ((Bool, String, SDKGroupItem?, [String: Any])->())?) {
//        var tempItem = item
//        //            限频操作
//        if let frequencyItems = frequencyControl?.baidu, let errorItems = xbAdError.baiduError[tempItem.placement ?? ""] {
//
//            let result = checkErrorCode(frequencyItems: frequencyItems, errorDic: errorItems)
//            if !result.0 {
//                var loadInfoItem: [String: Any] = [:]
//                loadInfoItem["ad"] = ["id": "",
//                                      "source": tempItem.source ?? "",
//                                      "placement_id": tempItem.placement ?? ""]
//                loadInfoItem["result"] = ["success": false,
//                                          "error": XbAdError.NATIVE_AD_NO_MORE_TRY_ERROR_CODE,
//                                          "placement_id": tempItem.placement ?? "",
//                                          "msg": XbAdError.NATIVE_AD_MSG_NO_MORE_TRY,
//                                          "trigger_code": result.1]
//                dPrint("----XBAD---XB_DU_AD保存---过滤---:", xbPlacement, tempItem.toJSON(), loadInfoItem)
//
//                complete?(false ,xbPlacement, nil, loadInfoItem)
//                return
//            }
//        }
//
//
//        dPrint("----XBAD---XB_DU_AD保存开始---:", xbPlacement, tempItem.toJSON())
//
//        fetchDUAd(item: tempItem, duplicate: duplicate ?? 1, complete: { (nativeAd, title, desc, result) in
//
//            var success: Bool = nativeAd != nil
//            var cacheResult = result
//            if duplicate != 1 && self.checkIsDuplicate(title: title, xbPlacement: xbPlacement) {
//                success = false
//                cacheResult = (XbAdError.NATIVE_AD_REDUNDANT_ERROR_CODE, XbAdError.NATIVE_AD_MSG_REDUNDANT, result.duration)
//            }
//
//            var loadInfoItem: [String: Any] = [:]
//            loadInfoItem["ad"] = ["id": "",
//                                  "source": tempItem.source ?? "",
//                                  "placement_id": tempItem.placement ?? "",
//                                  "title": title ,
//                                  "desc": desc]
//            loadInfoItem["result"] = ["success": success,
//                                      "error": cacheResult.errorCode,
//                                      "placement_id": tempItem.placement ?? "",
//                                      "msg": cacheResult.msg,
//                                      "duration": cacheResult.duration]
//
//            if success {
//                tempItem.title = title
//                tempItem.desc = desc
//                tempItem.duNativeAd = nativeAd
//
//                dPrint("----XBAD---XB_DU_AD保存成功---:", xbPlacement, tempItem.toJSON())
//                //  缓存 成功，清除改placement下的负面状态code
//                self.xbAdError.baiduError[tempItem.placement ?? ""] = nil
//            } else {
//
//                //                    广告请求的报错记录
//                if let errorItems = self.xbAdError.baiduError[tempItem.placement ?? ""] {
//                    if let error = errorItems[cacheResult.errorCode] {
//                        let tempError = error
//                        tempError.count += 1
//                        tempError.time = Date().timeIntervalSince1970
//                        self.xbAdError.baiduError[tempItem.placement ?? ""]?[cacheResult.errorCode] = tempError
//                    } else {
//                        let tempError = XbAdErrorItem()
//                        tempError.count = 1
//                        tempError.time = Date().timeIntervalSince1970
//                        self.xbAdError.baiduError[tempItem.placement ?? ""]?[cacheResult.errorCode] = tempError
//                    }
//
//                } else {
//                    var errorDic: [Int: XbAdErrorItem] = [:]
//                    let tempError = XbAdErrorItem()
//                    tempError.count = 1
//                    tempError.time = Date().timeIntervalSince1970
//                    errorDic[cacheResult.errorCode] = tempError
//                    self.xbAdError.baiduError[tempItem.placement ?? ""] = errorDic
//                }
//
//                dPrint("----XBAD---XB_DU_AD保存失败---:", xbPlacement, self.xbAdError.toJSON(), loadInfoItem)
//
//            }
//            complete?(success ,xbPlacement, tempItem, loadInfoItem)
//
//        })
//    }
//}
//
//// MARK: - 缓存MTG广告
//extension XbAdManager {
//    // 从缓存中取出MTG广告
//    func getMTGNativeAd(xbPlacement: XBPlacementType, placementId : String, price: Double) -> (Bool, MTGAdModel?, SDKGroupItem?) {
//        guard let group = preloadingXBAdes[xbPlacement.rawValue], group.count > 0 else {
//            return (false, nil, nil)
//        }
//        var currentItem: SDKGroupItem?
//        for (index, item) in group.enumerated() {
//            if item.placement == placementId, item.price == price {
//                currentItem = item
//                preloadingXBAdes[xbPlacement.rawValue]?.remove(at: index)
//                dPrint("----XBAD---XB_缓存池状态---消耗---:", xbPlacement.rawValue, preloadingXBAdes[xbPlacement.rawValue]?.count)
//                break
//            }
//        }
//        if currentItem != nil && Date().timeIntervalSince1970 - (currentItem?.cacheTime ?? 0) > (currentItem?.cacheValidTime ?? 0) {
//            return getMTGNativeAd(xbPlacement: xbPlacement, placementId: placementId, price: price)
//        }
//        return (currentItem?.mtgAdModel != nil, currentItem?.mtgAdModel, currentItem)
//    }
//
//    // 请求缓存MTG广告
//    func cacheMTGNativeAd(xbPlacement: String, item: SDKGroupItem, duplicate: Int?, frequencyControl: FrequencyControl?, complete: ((Bool, String, SDKGroupItem?, [String: Any])->())?) {
//        var tempItem = item
//        //            限频操作
//        if let frequencyItems = frequencyControl?.mintegral, let errorItems = xbAdError.mtgError[tempItem.placement ?? ""] {
//
//            let result = checkErrorCode(frequencyItems: frequencyItems, errorDic: errorItems)
//            if !result.0 {
//                var loadInfoItem: [String: Any] = [:]
//                loadInfoItem["ad"] = ["id": "",
//                                      "source": tempItem.source ?? "",
//                                      "placement_id": tempItem.placement ?? ""]
//                loadInfoItem["result"] = ["success": false,
//                                          "error": XbAdError.NATIVE_AD_NO_MORE_TRY_ERROR_CODE,
//                                          "placement_id": tempItem.placement ?? "",
//                                          "msg": XbAdError.NATIVE_AD_MSG_NO_MORE_TRY,
//                                          "trigger_code": result.1]
//                dPrint("----XBAD---XB_MTG_AD保存---过滤---:", xbPlacement, tempItem.toJSON(), loadInfoItem)
//
//                complete?(false ,xbPlacement, nil, loadInfoItem)
//                return
//            }
//        }
//
//
//        dPrint("----XBAD---XB_MTG_AD保存开始---:", xbPlacement, tempItem.toJSON())
//
//        fetchMTGAd(item: tempItem, duplicate: duplicate ?? 1, complete: { (adModel, title, desc, result) in
//
//            var success: Bool = adModel != nil
//            var cacheResult = result
//            if duplicate != 1 && self.checkIsDuplicate(title: title, xbPlacement: xbPlacement) {
//                success = false
//                cacheResult = (XbAdError.NATIVE_AD_REDUNDANT_ERROR_CODE, XbAdError.NATIVE_AD_MSG_REDUNDANT, result.duration)
//            }
//
//            var loadInfoItem: [String: Any] = [:]
//            loadInfoItem["ad"] = ["id": "",
//                                  "source": tempItem.source ?? "",
//                                  "placement_id": tempItem.placement ?? "",
//                                  "title": title ,
//                                  "desc": desc]
//            loadInfoItem["result"] = ["success": success,
//                                      "error": cacheResult.errorCode,
//                                      "placement_id": tempItem.placement ?? "",
//                                      "msg": cacheResult.msg,
//                                      "duration": cacheResult.duration]
//
//            if success {
//                tempItem.title = title
//                tempItem.desc = desc
//                tempItem.mtgAdModel = adModel
//
//                dPrint("----XBAD---XB_MTG_AD保存成功---:", xbPlacement, tempItem.toJSON())
//                //  缓存 成功，清除改placement下的负面状态code
//                self.xbAdError.mtgError[tempItem.placement ?? ""] = nil
//            } else {
//
//                //                    广告请求的报错记录
//                if let errorItems = self.xbAdError.mtgError[tempItem.placement ?? ""] {
//                    if let error = errorItems[cacheResult.errorCode] {
//                        let tempError = error
//                        tempError.count += 1
//                        tempError.time = Date().timeIntervalSince1970
//                        self.xbAdError.mtgError[tempItem.placement ?? ""]?[cacheResult.errorCode] = tempError
//                    } else {
//                        let tempError = XbAdErrorItem()
//                        tempError.count = 1
//                        tempError.time = Date().timeIntervalSince1970
//                        self.xbAdError.mtgError[tempItem.placement ?? ""]?[cacheResult.errorCode] = tempError
//                    }
//
//                } else {
//                    var errorDic: [Int: XbAdErrorItem] = [:]
//                    let tempError = XbAdErrorItem()
//                    tempError.count = 1
//                    tempError.time = Date().timeIntervalSince1970
//                    errorDic[cacheResult.errorCode] = tempError
//                    self.xbAdError.mtgError[tempItem.placement ?? ""] = errorDic
//                }
//
//                dPrint("----XBAD---XB_MTG_AD保存失败---:", xbPlacement, self.xbAdError.toJSON(), loadInfoItem)
//
//            }
//            complete?(success ,xbPlacement, tempItem, loadInfoItem)
//
//        })
//    }
//}
//
//// MARK: - 缓存Appnext广告
//extension XbAdManager {
//    // 从缓存中取出Appnext广告
//    func getAppnextNativeAd(xbPlacement: XBPlacementType, placementId : String, price: Double) -> (Bool, AppnextAdModel?, SDKGroupItem?) {
//        guard let group = preloadingXBAdes[xbPlacement.rawValue], group.count > 0 else {
//            return (false, nil, nil)
//        }
//        var currentItem: SDKGroupItem?
//        for (index, item) in group.enumerated() {
//            if item.placement == placementId, item.price == price {
//                currentItem = item
//                preloadingXBAdes[xbPlacement.rawValue]?.remove(at: index)
//                dPrint("----XBAD---XB_缓存池状态---消耗---:", xbPlacement.rawValue, preloadingXBAdes[xbPlacement.rawValue]?.count)
//                break
//            }
//        }
//        if currentItem != nil && Date().timeIntervalSince1970 - (currentItem?.cacheTime ?? 0) > (currentItem?.cacheValidTime ?? 0) {
//            return getAppnextNativeAd(xbPlacement: xbPlacement, placementId: placementId, price: price)
//        }
//        return (currentItem?.appnextAdModel != nil, currentItem?.appnextAdModel, currentItem)
//    }
//
//    // 请求缓存Appnext广告
//    func cacheAppnextNativeAd(xbPlacement: String, item: SDKGroupItem, duplicate: Int?, frequencyControl: FrequencyControl?, complete: ((Bool, String, SDKGroupItem?, [String: Any])->())?) {
//        var tempItem = item
//        //            限频操作
//        if let frequencyItems = frequencyControl?.appnext, let errorItems = xbAdError.appnextError[tempItem.placement ?? ""] {
//
//            let result = checkErrorCode(frequencyItems: frequencyItems, errorDic: errorItems)
//            if !result.0 {
//                var loadInfoItem: [String: Any] = [:]
//                loadInfoItem["ad"] = ["id": "",
//                                      "source": tempItem.source ?? "",
//                                      "placement_id": tempItem.placement ?? ""]
//                loadInfoItem["result"] = ["success": false,
//                                          "error": XbAdError.NATIVE_AD_NO_MORE_TRY_ERROR_CODE,
//                                          "placement_id": tempItem.placement ?? "",
//                                          "msg": XbAdError.NATIVE_AD_MSG_NO_MORE_TRY,
//                                          "trigger_code": result.1]
//                dPrint("----XBAD---XB_APPNEXT_AD保存---过滤---:", xbPlacement, tempItem.toJSON(), loadInfoItem)
//
//                complete?(false ,xbPlacement, nil, loadInfoItem)
//                return
//            }
//        }
//
//
//        dPrint("----XBAD---XB_APPNEXT_AD保存开始---:", xbPlacement, tempItem.toJSON())
//
//        fetchAppnextAd(item: tempItem, duplicate: duplicate ?? 1, complete: { (model, title, desc, result) in
//
//            var success: Bool = model != nil
//            var cacheResult = result
//            if duplicate != 1 && self.checkIsDuplicate(title: title, xbPlacement: xbPlacement) {
//                success = false
//                cacheResult = (XbAdError.NATIVE_AD_REDUNDANT_ERROR_CODE, XbAdError.NATIVE_AD_MSG_REDUNDANT, result.duration)
//            }
//
//            var loadInfoItem: [String: Any] = [:]
//            loadInfoItem["ad"] = ["id": "",
//                                  "source": tempItem.source ?? "",
//                                  "placement_id": tempItem.placement ?? "",
//                                  "title": title ,
//                                  "desc": desc]
//            loadInfoItem["result"] = ["success": success,
//                                      "error": cacheResult.errorCode,
//                                      "placement_id": tempItem.placement ?? "",
//                                      "msg": cacheResult.msg,
//                                      "duration": cacheResult.duration]
//
//            if success {
//                tempItem.title = title
//                tempItem.desc = desc
//                tempItem.appnextAdModel = model
//
//                dPrint("----XBAD---XB_APPNEXT_AD保存成功---:", xbPlacement, tempItem.toJSON())
//                //  缓存 成功，清除改placement下的负面状态code
//                self.xbAdError.appnextError[tempItem.placement ?? ""] = nil
//            } else {
//
//                //                    广告请求的报错记录
//                if let errorItems = self.xbAdError.appnextError[tempItem.placement ?? ""] {
//                    if let error = errorItems[cacheResult.errorCode] {
//                        let tempError = error
//                        tempError.count += 1
//                        tempError.time = Date().timeIntervalSince1970
//                        self.xbAdError.appnextError[tempItem.placement ?? ""]?[cacheResult.errorCode] = tempError
//                    } else {
//                        let tempError = XbAdErrorItem()
//                        tempError.count = 1
//                        tempError.time = Date().timeIntervalSince1970
//                        self.xbAdError.appnextError[tempItem.placement ?? ""]?[cacheResult.errorCode] = tempError
//                    }
//
//                } else {
//                    var errorDic: [Int: XbAdErrorItem] = [:]
//                    let tempError = XbAdErrorItem()
//                    tempError.count = 1
//                    tempError.time = Date().timeIntervalSince1970
//                    errorDic[cacheResult.errorCode] = tempError
//                    self.xbAdError.appnextError[tempItem.placement ?? ""] = errorDic
//                }
//
//                dPrint("----XBAD---XB_APPNEXT_AD保存失败---:", xbPlacement, self.xbAdError.toJSON(), loadInfoItem)
//
//            }
//            complete?(success ,xbPlacement, tempItem, loadInfoItem)
//
//        })
//    }
//}
