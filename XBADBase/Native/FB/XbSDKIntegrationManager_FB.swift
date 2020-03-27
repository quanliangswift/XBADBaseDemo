//
//  XbSDKIntegrationManager_FB.swift
//  XBADBaseDemo
//
//  Created by 全尼古拉斯 on 2020/3/26.
//  Copyright © 2020 全尼古拉斯. All rights reserved.
//

import Foundation
import FBAudienceNetwork

extension XbSDKIntegrationManager {
    /// 对外接口， 提供所需的FB广告
    /// 聚合广告
    /// - Parameters:
    ///   - xbPlacement:
    ///   - placementId:
    /// - Returns:
    func getXbFBNativeAd(xbPlacement: XBPlacementType, placementId : String, price: Double) -> (Bool, FBNativeAd?, SDKGroupItem?) {
        let item = getXbSDKIntegration(by: xbPlacement)
        
        if item.0 == nil {
            return (false, nil, nil)
        }
        let result = XbAdManager.shared.getFBNativeAd(xbPlacement: xbPlacement, placementId: placementId, price: price)
        return result
    }
}
