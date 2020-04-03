//
//  XbSDKIntegrationManager_FB.swift
//  XBADBaseDemo
//
//  Created by 全尼古拉斯 on 2020/3/26.
//  Copyright © 2020 全尼古拉斯. All rights reserved.
//

import Foundation
import GoogleMobileAds

extension XbSDKIntegrationManager {
    /// 对外接口， 提供所需的Google广告
        /// 聚合广告
        /// - Parameters:
        ///   - xbPlacement:
        ///   - placementId:
        /// - Returns:
        func getXbGoogleNativeAd(xbPlacement: XBPlacementType, placementId : String, price: Double) -> (Bool, GADUnifiedNativeAd?, SDKGroupItem?) {
            let item = getXbSDKIntegration(by: xbPlacement)
            if item.0 == nil {
                return (false, nil, nil)
            }
    //        guard let item = getXbSDKIntegration(by: xbPlacement) else {return (false, nil, nil)}
            let result = XbAdManager.shared.getGoogleNativeAd(xbPlacement: xbPlacement, placementId: placementId, price: price)
    //        XbAdManager.shared.startCacheXbAd(by: item.0!, finished: nil)
            return result
        }
}
