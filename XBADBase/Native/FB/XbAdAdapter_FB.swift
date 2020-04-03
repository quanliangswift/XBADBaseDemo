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
    func getFBNativeAd(placementId: String, xbPlacement: String, type: String, price: Double) -> (Bool,  FBNativeAd?, SDKGroupItem?) {
        switch type {
        case AdSourceType.sdk.rawValue:
            let result = FBNativeAdManager.shared.getFBNativeAd(placementId: placementId)
            return (result.0, result.1, nil)
        case AdSourceType.sharp.rawValue:
            return XbSDKIntegrationManager.shared.getXbFBNativeAd(xbPlacement: XBPlacementType(rawValue: xbPlacement)!, placementId: placementId, price: price)
        default:
            return (false, nil, nil)
        }
    }
    
    func getFBNativeAdView(ad: Any) -> XBNativeAdBaseView {
        let view = Bundle.main.loadNibNamed("FacebookNativeAdView", owner: nil, options: nil)?.first as! FacebookNativeAdView
        view.nativeAd = ad as! FBNativeAd
        return view
    }
    func getFBNativeAdSView(ad: Any) -> XBNativeAdBaseView {
        let view = Bundle.main.loadNibNamed("FacebookNativeAdSView", owner: nil, options: nil)?.first as! FacebookNativeAdSView
        view.nativeAd = ad as! FBNativeAd
        return view
    }
}
