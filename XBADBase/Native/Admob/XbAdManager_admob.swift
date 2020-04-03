//
//  XbAdManager_FB.swift
//  XBADBaseDemo
//
//  Created by 全尼古拉斯 on 2020/3/26.
//  Copyright © 2020 全尼古拉斯. All rights reserved.
//

import Foundation
import GoogleMobileAds

extension SDKGroupItem {
    var googleNativeAd: GADUnifiedNativeAd? {
        get {
            return nativeAd as? GADUnifiedNativeAd
        }
        set {
            nativeAd = newValue
        }
    }
}


// MARK: - 缓存Google广告
extension XbAdManager {
    // 从缓存中取出Google广告
    func getGoogleNativeAd(xbPlacement: XBPlacementType, placementId : String, price: Double) -> (Bool, GADUnifiedNativeAd?, SDKGroupItem?) {
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
            return getGoogleNativeAd(xbPlacement: xbPlacement, placementId: placementId, price: price)
        }
        return (currentItem?.googleNativeAd != nil, currentItem?.googleNativeAd, currentItem)
    }
    
    func registerAdmob(key: String) {
        nativeAdDelegates[key] = XbGoogleAdManager.shared
    }
}
