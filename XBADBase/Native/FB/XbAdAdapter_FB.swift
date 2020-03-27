//
//  XbAdAdapter_FB.swift
//  XBADBaseDemo
//
//  Created by 全尼古拉斯 on 2020/3/26.
//  Copyright © 2020 全尼古拉斯. All rights reserved.
//

import UIKit
import FBAudienceNetwork

extension XbAdAdapter {
    func getFBNativeAd(placementId: String, xbPlacement: String, source: AdSourceType, price: Double) -> (Bool,  FBNativeAd?, SDKGroupItem?) {
        switch  source {
        case .sdk:
            let result = FBNativeAdManager.shared.getFBNativeAd(placementId: placementId)
            return (result.0, result.1, nil)
        case .sharp:
            return XbSDKIntegrationManager.shared.getXbFBNativeAd(xbPlacement: XBPlacementType(rawValue: xbPlacement)!, placementId: placementId, price: price)
        default:
            return (false, nil, nil)
        }
    }
}
