//
//  XbAdAdapter_FB.swift
//  XBADBaseDemo
//
//  Created by 全尼古拉斯 on 2020/3/26.
//  Copyright © 2020 全尼古拉斯. All rights reserved.
//

import UIKit

extension XbAdAdapter {
    func getMTGNativeAd(placementId: String, xbPlacement: String, type: String, price: Double) -> (Bool,  MTGAdModel?, SDKGroupItem?) {
        switch type {
        case AdSourceType.sdk.rawValue:
            let result = MTG_NativeAdManager.shared.getMTGNativeAd(adUnitID: placementId)
            return (result.0, result.1, nil)
        case AdSourceType.sharp.rawValue:
            return XbSDKIntegrationManager.shared.getXbMTGNativeAd(xbPlacement: XBPlacementType(rawValue: xbPlacement)!, placementId: placementId, price: price)
        default:
            return (false, nil, nil)
        }
    }
    
    func getMTGNativeAdView(ad: Any) -> XBNativeAdBaseView {
        let view = Bundle.main.loadNibNamed("MTGNativeAdView", owner: nil, options: nil)?.first as! MTGNativeAdView
        view.mtgAdModel = ad as? MTGAdModel
        return view
    }
    func getMTGNativeAdSView(ad: Any) -> XBNativeAdBaseView {
        let view = Bundle.main.loadNibNamed("MTGNativeAdSView", owner: nil, options: nil)?.first as! MTGNativeAdSView
        view.mtgAdModel = ad as? MTGAdModel
        return view
    }
}
