//
//  XbAdAdapter_FB.swift
//  XBADBaseDemo
//
//  Created by 全尼古拉斯 on 2020/3/26.
//  Copyright © 2020 全尼古拉斯. All rights reserved.
//

import UIKit
import DUModuleSDK
extension XbAdAdapter {
    func getDUNativeAd(placementId: String, xbPlacement: String, type: String, price: Double) -> (Bool,  DUNativeAd?, SDKGroupItem?) {
        switch  type {
        case AdSourceType.sdk.rawValue:
            let result = DUNativeAdManager.shared.getDUNativeAd(placementId: placementId)
            return (result.0, result.1, nil)
        case AdSourceType.sdk.rawValue:

            return XbSDKIntegrationManager.shared.getXbDUNativeAd(xbPlacement: XBPlacementType(rawValue: xbPlacement)!, placementId: placementId, price: price)
        default:
            return (false, nil, nil)
        }
    }
    

}
