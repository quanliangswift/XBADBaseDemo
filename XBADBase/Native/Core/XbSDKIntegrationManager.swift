//
//  XbSDKIntegrationManager.swift
//  TopNews
//
//  Created by xb on 2019/3/21.
//  Copyright © 2019年 xb. All rights reserved.
//

import UIKit
enum XbSDKIntegrationAdType: String {
    case nativeAd
    case interstitialAd
    case rewardedVideoAd
}

class XbSDKIntegrationManager: NSObject {
    static let shared = XbSDKIntegrationManager()
    //  是否成功拉到配置
    var fetchSuccess: Bool = false

    var xbAdIntegration: XbAdIntegration = XbAdIntegration()
//    func getSdkIntegrationConfig(isFirst: Bool) {
//        if !isFirst && fetchSuccess {
//            return
//        }
//        fetchSuccess = true
//        ApiaAPI.getXbSKDIntegration(onSuccessed: { (xbAdIntegration) in
//            self.fetchSuccess = true
//            self.registerConfig(xbAdIntegration: xbAdIntegration)
//        }, onFailed: { (status, msg) in
//            self.fetchSuccess = false
//        }, onError: {
//            self.fetchSuccess = false
//        })
//    }
    
    func registerConfig(xbAdIntegration: XbAdIntegration) {
        dPrint(xbAdIntegration)
        dPrint(xbAdIntegration.nativeAdsJson)
        dPrint(xbAdIntegration.interstitialAdsJson)
        dPrint(xbAdIntegration.rewardedVideoAdsJson)
        var isNativeChange: Bool = false
        var isInterstitialChange: Bool = false
        var isRewardedVideoChange: Bool = false
        // 配置有变，删除旧的缓存
        if let old = self.xbAdIntegration.nativeAdsJson?.stringValue {
            if let new = xbAdIntegration.nativeAdsJson?.stringValue,
                !new.elementsEqual(old) {
                XbAdManager.shared.removeAllOldAd()
                isNativeChange = true
            }
        } else {
            isNativeChange = true
        }
        
//        if let old = self.xbAdIntegration.rewardedVideoAdsJson?.stringValue {
//            if let new = xbAdIntegration.rewardedVideoAdsJson?.stringValue,
//                !new.elementsEqual(old) {
//                XBRewardVideoManager.shared.removeOldXbAdCache()
//                isRewardedVideoChange = true
//            }
//        } else {
//            isRewardedVideoChange = true
//        }
//
//        if let old = self.xbAdIntegration.interstitialAdsJson?.stringValue {
//            if let new = xbAdIntegration.interstitialAdsJson?.stringValue,
//                !new.elementsEqual(old) {
//                XbInterstitialAdIntegrationManager.shared.removeOldXbAdCache()
//                isInterstitialChange = true
//            }
//        } else {
//            isInterstitialChange = true
//        }
        
        
        self.xbAdIntegration = xbAdIntegration
        
        // 按照priority来对xb_placement排序
        // feeds>article_bottom>relative>reward_popup
        self.xbAdIntegration.nativeAds = self.xbAdIntegration.nativeAds.sorted(by: {
            $0.priority > $1.priority
        })
        self.xbAdIntegration.rewardedVideoAds = self.xbAdIntegration.rewardedVideoAds.sorted(by: {
            $0.priority > $1.priority
        })
        self.xbAdIntegration.interstitialAds = self.xbAdIntegration.interstitialAds.sorted(by: {
            $0.priority > $1.priority
        })
        // 对SDKgroup进行价格排序
        self.xbAdIntegration.nativeAds = self.xbAdIntegration.nativeAds.map({ (item) -> XbSDKIntegration in
            let group = item.sdkGroup?.sorted(by: {
                $0.price > $1.price
            })
            item.sdkGroup = group
            return item
        })
        self.xbAdIntegration.rewardedVideoAds = self.xbAdIntegration.rewardedVideoAds.map({ (item) -> XbSDKIntegration in
            let group = item.sdkGroup?.sorted(by: {
                $0.price > $1.price
            })
            item.sdkGroup = group
            return item
        })
        self.xbAdIntegration.interstitialAds = self.xbAdIntegration.interstitialAds.map({ (item) -> XbSDKIntegration in
            let group = item.sdkGroup?.sorted(by: {
                $0.price > $1.price
            })
            item.sdkGroup = group
            return item
        })
        
        // native, RV, 插屏 分别间隔10秒开始
        if isNativeChange {
            self.checkGroupConfig(forNativeAd: xbAdIntegration.nativeAds)
        }
//        if isRewardedVideoChange {
//            DelayTimer.delay(10, task: {
//                XBRewardVideoManager.shared.checkGroupConfig(forRewardedVideo: xbAdIntegration.rewardedVideoAds)
//            })
//        }
//        if isInterstitialChange {
//            DelayTimer.delay(20, task: {
//                XbInterstitialAdIntegrationManager.shared.checkGroupConfig(forInterstitial: xbAdIntegration.interstitialAds)
//            })
//        }
    }
    
    /// 检查广告配置，是否有改动而删除旧的缓存广告
    /// 原生广告
    /// - Parameter integrations:
    private func checkGroupConfig(forNativeAd integrations: [XbSDKIntegration]) {
        tryCacheAllAd()
    }
    
    func tryCacheAllAd() {
        cacheAd(by: 0)
    }
    
    func cacheAd(by index: Int) {
        if index < self.xbAdIntegration.nativeAds.count {
            let item = self.xbAdIntegration.nativeAds[index]
            startCachead(by: item, finished: { [weak self] in
                // 缓存奖励红包广告
                // FIXME: -test
//                if item.xbPlacement == "reward_popup" {
//                    XBRewardAdManager.shared.tryCacheRewardAd()
//                }
                self?.cacheAd(by: index + 1)
            })
        }
    }
    // APP从后台被唤醒的时候检查广告是否过期
    func checkAllTimeout() {
        for item in self.xbAdIntegration.nativeAds {
            XbAdManager.shared.checkTimeout(by: item.xbPlacement ?? "")
        }
    }
    // 拉取到配置，填充缓存池
    func startCachead(by group: XbSDKIntegration, finished: (() -> ())?) {
        XbAdManager.shared.startCacheXbAd(by: group, finished: finished)
    }
    
    // 消耗了缓存之后，填充缓存池
    func startCheckCacheNum(xbPlacement: XBPlacementType) {
        if let group = getXbSDKIntegration(by: xbPlacement).0 {
            XbAdManager.shared.startCacheXbAd(by: group, finished: nil)
        }
    }
    
    func removeOldXbAdCache(item: XbSDKIntegration) {
        XbAdManager.shared.removeCacheXbAd(by: item)
    }
    
    /// 对外接口： 获取请求中缓存的配置
    ///
    func getXbAdParams(by xbPlacement: XBPlacementType) -> String {
        let xbAds = XbSDKIntegrationManager.shared.getXBAds(by: xbPlacement)
        var sdkCache: [String: Any] = ["xb_placement": xbPlacement.rawValue]
        var group: [[String: Any]] = []
        for ad in xbAds {
            var item: [String: Any] = [:]
            item["source"] = ad.source
            item["placement"] = ad.placement
            item["price"] = ad.price
            item["title"] = ad.title
            item["desc"] = ad.desc
            group.append(item)
        }
        sdkCache["sdk_group"] = group
        return sdkCache.toJSONString() ?? ""
    }
    
    
    /// 获取已经缓存的XBAd
    ///
    private func getXBAds(by xbPlacement: XBPlacementType) -> [SDKGroupItem] {
        var group: [SDKGroupItem] = []
        let item = getXbSDKIntegration(by: xbPlacement)
        if item.0 == nil {return group}
        group = XbAdManager.shared.getXbAd(by: item.0!, slots: item.1)
        return group
    }
    
    func getXbSDKIntegration(by xbPlacement: XBPlacementType) -> (XbSDKIntegration?, Int) {
        if xbPlacement == .none {return (nil, 0)}
        var integration: XbSDKIntegration?
        var slots: Int = 0
        for item in self.xbAdIntegration.nativeAds {
            if item.xbPlacement == xbPlacement.rawValue {
                slots = item.slots ?? 0
                if integration == nil {
                    integration = item
                }
                break
            }
        }
        return (integration, slots)
    }    
}

extension XbSDKIntegrationManager {
//    /// 对外接口， 提供所需的FB广告
//    /// 聚合广告
//    /// - Parameters:
//    ///   - xbPlacement:
//    ///   - placementId:
//    /// - Returns:
//    func getXbFBNativeAd(xbPlacement: XBPlacementType, placementId : String, price: Double) -> (Bool, FBNativeAd?, SDKGroupItem?) {
//        let item = getXbSDKIntegration(by: xbPlacement)
//        
//        if item.0 == nil {
//            return (false, nil, nil)
//        }
//        let result = XbAdManager.shared.getFBNativeAd(xbPlacement: xbPlacement, placementId: placementId, price: price)
////        XbAdManager.shared.startCacheXbAd(by: item.0!, finished: nil)
//
//        return result
//    }
//
//    /// 对外接口， 提供所需的Google广告
//    /// 聚合广告
//    /// - Parameters:
//    ///   - xbPlacement:
//    ///   - placementId:
//    /// - Returns:
//    func getXbGoogleNativeAd(xbPlacement: XBPlacementType, placementId : String, price: Double) -> (Bool, GADUnifiedNativeAd?, SDKGroupItem?) {
//        let item = getXbSDKIntegration(by: xbPlacement)
//        if item.0 == nil {
//            return (false, nil, nil)
//        }
////        guard let item = getXbSDKIntegration(by: xbPlacement) else {return (false, nil, nil)}
//        let result = XbAdManager.shared.getGoogleNativeAd(xbPlacement: xbPlacement, placementId: placementId, price: price)
////        XbAdManager.shared.startCacheXbAd(by: item.0!, finished: nil)
//        return result
//    }
//
//    /// 对外接口， 提供所需的FB广告
//    /// 聚合广告
//    /// - Parameters:
//    ///   - xbPlacement:
//    ///   - placementId:
//    /// - Returns:
//    func getXbDUNativeAd(xbPlacement: XBPlacementType, placementId : String, price: Double) -> (Bool, DUNativeAd?, SDKGroupItem?) {
//        let item = getXbSDKIntegration(by: xbPlacement)
//        if item.0 == nil {
//            return (false, nil, nil)
//        }
//        let result = XbAdManager.shared.getDUNativeAd(xbPlacement: xbPlacement, placementId: placementId, price: price)
////        XbAdManager.shared.startCacheXbAd(by: item.0!, finished: nil)
//
//        return result
//    }
//
//    /// 对外接口， 提供所需的Appnext广告
//    /// 聚合广告
//    /// - Parameters:
//    ///   - xbPlacement:
//    ///   - placementId:
//    /// - Returns:
//    func getXbAppnextNativeAd(xbPlacement: XBPlacementType, placementId : String, price: Double) -> (Bool, AppnextAdModel?, SDKGroupItem?) {
//        let item = getXbSDKIntegration(by: xbPlacement)
//        if item.0 == nil {
//            return (false, nil, nil)
//        }
//
//        let result = XbAdManager.shared.getAppnextNativeAd(xbPlacement: xbPlacement, placementId: placementId, price: price)
////        XbAdManager.shared.startCacheXbAd(by: item.0!, finished: nil)
//
//        return result
//    }
//    /// 对外接口， 提供所需的MTG广告
//    /// 聚合广告
//    /// - Parameters:
//    ///   - xbPlacement:
//    ///   - placementId:
//    /// - Returns:
//    func getXbMTGNativeAd(xbPlacement: XBPlacementType, placementId : String, price: Double) -> (Bool, MTGAdModel?, SDKGroupItem?) {
//        let item = getXbSDKIntegration(by: xbPlacement)
//        if item.0 == nil {
//            return (false, nil, nil)
//        }
//
//        let result = XbAdManager.shared.getMTGNativeAd(xbPlacement: xbPlacement, placementId: placementId, price: price)
////        XbAdManager.shared.startCacheXbAd(by: item.0!, finished: nil)
//
//        return result
//    }
}
