//
//  XbAdManager_FB.swift
//  XBADBaseDemo
//
//  Created by 全尼古拉斯 on 2020/3/26.
//  Copyright © 2020 全尼古拉斯. All rights reserved.
//

import Foundation
import DUModuleSDK

extension SDKGroupItem {
    var duNativeAd: DUNativeAd? {
        get {
            return nativeAd as? DUNativeAd
        }
        set {
            nativeAd = newValue
        }
    }
}

// MARK: - 缓存BaiDu广告
extension XbAdManager {
    // 从缓存中取出BaiDu广告
    func getDUNativeAd(xbPlacement: XBPlacementType, placementId : String, price: Double) -> (Bool, DUNativeAd?, SDKGroupItem?) {
        guard let group = preloadingXBAdes[xbPlacement.rawValue], group.count > 0 else {
            return (false, nil, nil)
        }
        var currentItem: SDKGroupItem?
        for (index, item) in group.enumerated() {
            if item.placement == placementId, item.price == price {
                currentItem = item
                preloadingXBAdes[xbPlacement.rawValue]?.remove(at: index)
                print("----XBAD---XB_缓存池状态---消耗---:", xbPlacement.rawValue, preloadingXBAdes[xbPlacement.rawValue]?.count)
                break
            }
        }
        if currentItem != nil && Date().timeIntervalSince1970 - (currentItem?.cacheTime ?? 0) > (currentItem?.cacheValidTime ?? 0) {
            return getDUNativeAd(xbPlacement: xbPlacement, placementId: placementId, price: price)
        }
        return (currentItem?.duNativeAd != nil, currentItem?.duNativeAd, currentItem)
    }

    func registerBaidu(key: String) {
        nativeAdDelegates[key] = XbDUAdManager.shared
    }
}

