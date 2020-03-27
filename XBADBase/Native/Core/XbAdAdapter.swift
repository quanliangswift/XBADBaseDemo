//
//  XbAdAdapter.swift
//  TopNews
//
//  Created by xb on 2019/3/30.
//  Copyright © 2019年 xb. All rights reserved.
//

import UIKit
//import FBAudienceNetwork
//import GoogleMobileAds
//import DUModuleSDK


class XbAdAdapter: NSObject {
    static let shared = XbAdAdapter()
//    func getFBNativeAd(placementId: String, xbPlacement: String, source: AdSourceType, price: Double) -> (Bool,  FBNativeAd?, SDKGroupItem?) {
//        switch  source {
//        case .sdk:
//            let result = FBNativeAdManager.shared.getFBNativeAd(placementId: placementId)
//            return (result.0, result.1, nil)
//        case .sharp:
//            return XbSDKIntegrationManager.shared.getXbFBNativeAd(xbPlacement: XBPlacementType(rawValue: xbPlacement)!, placementId: placementId, price: price)
//        default:
//            return (false, nil, nil)
//        }
//    }
//    func getGoogleNativeAd(placementId: String, xbPlacement: String, source: AdSourceType, price: Double) -> (Bool, GADUnifiedNativeAd?, SDKGroupItem?) {
//        switch  source {
//        case .sdk:
//            let result = GoogleNativeAdManager.shared.getGoogleNativeAd(adUnitID: placementId)
//            return (result.0, result.1, nil)
//        case .sharp:
//            return XbSDKIntegrationManager.shared.getXbGoogleNativeAd(xbPlacement: XBPlacementType(rawValue: xbPlacement)!, placementId: placementId, price: price)
//        default:
//            return (false, nil, nil)
//        }
//    }
//    
//    func getDUNativeAd(placementId: String, xbPlacement: String, source: AdSourceType, price: Double) -> (Bool,  DUNativeAd?, SDKGroupItem?) {
//        switch  source {
//        case .sdk:
//            let result = DUNativeAdManager.shared.getDUNativeAd(placementId: placementId)
//            return (result.0, result.1, nil)
//        case .sharp:
//            
//            return XbSDKIntegrationManager.shared.getXbDUNativeAd(xbPlacement: XBPlacementType(rawValue: xbPlacement)!, placementId: placementId, price: price)
//        default:
//            return (false, nil, nil)
//        }
//    }
//    func getAppnextNativeAd(placementId: String, xbPlacement: String, source: AdSourceType, price: Double) -> (Bool,  AppnextAdModel?, SDKGroupItem?) {
//        switch  source {
//        case .sdk:
//            let result = AppnextNativeAdManager.shared.getAppnextNativeAd(placementId: placementId)
//            return (result.0, result.1, nil)
//        case .sharp:
//            
//            return XbSDKIntegrationManager.shared.getXbAppnextNativeAd(xbPlacement: XBPlacementType(rawValue: xbPlacement)!, placementId: placementId, price: price)
//        default:
//            return (false, nil, nil)
//        }
//    }
//    
//    func getMTGNativeAd(placementId: String, xbPlacement: String, source: AdSourceType, price: Double) -> (Bool,  MTGAdModel?, SDKGroupItem?) {
//        switch  source {
//        case .sdk:
//            let result = MTG_NativeAdManager.shared.getMTGNativeAd(adUnitID: placementId)
//            return (result.0, result.1, nil)
//        case .sharp:
//            return XbSDKIntegrationManager.shared.getXbMTGNativeAd(xbPlacement: XBPlacementType(rawValue: xbPlacement)!, placementId: placementId, price: price)
//        default:
//            return (false, nil, nil)
//        }
//    }
}
