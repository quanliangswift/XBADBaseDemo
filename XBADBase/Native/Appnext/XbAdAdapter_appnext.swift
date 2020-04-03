//
//  XbAdAdapter_FB.swift
//  XBADBaseDemo
//
//  Created by 全尼古拉斯 on 2020/3/26.
//  Copyright © 2020 全尼古拉斯. All rights reserved.
//

import UIKit

extension XbAdAdapter {
    func getAppnextNativeAd(placementId: String, xbPlacement: String, type: String, price: Double) -> (Bool,  AppnextAdModel?, SDKGroupItem?) {
        switch type {
        case AdSourceType.sdk.rawValue:
            let result = AppnextNativeAdManager.shared.getAppnextNativeAd(placementId: placementId)
            return (result.0, result.1, nil)
        case AdSourceType.sharp.rawValue:

            return XbSDKIntegrationManager.shared.getXbAppnextNativeAd(xbPlacement: XBPlacementType(rawValue: xbPlacement)!, placementId: placementId, price: price)
        default:
            return (false, nil, nil)
        }
    }
}
