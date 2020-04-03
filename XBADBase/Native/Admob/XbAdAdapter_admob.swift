//
//  XbAdAdapter_FB.swift
//  XBADBaseDemo
//
//  Created by 全尼古拉斯 on 2020/3/26.
//  Copyright © 2020 全尼古拉斯. All rights reserved.
//

import UIKit
import GoogleMobileAds

extension XbAdAdapter {
    func getGoogleNativeAd(placementId: String, xbPlacement: String, type: String, price: Double) -> (Bool, GADUnifiedNativeAd?, SDKGroupItem?) {
        switch type {
        case AdSourceType.sdk.rawValue:
            let result = GoogleNativeAdManager.shared.getGoogleNativeAd(adUnitID: placementId)
            return (result.0, result.1, nil)
        case AdSourceType.sharp.rawValue:
            return XbSDKIntegrationManager.shared.getXbGoogleNativeAd(xbPlacement: XBPlacementType(rawValue: xbPlacement)!, placementId: placementId, price: price)
        default:
            return (false, nil, nil)
        }
    }
    
}
