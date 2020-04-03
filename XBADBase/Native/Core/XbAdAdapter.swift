//
//  XbAdAdapter.swift
//  TopNews
//
//  Created by xb on 2019/3/30.
//  Copyright © 2019年 xb. All rights reserved.
//

import UIKit
protocol AdapterNativeAdDelegate: class {
    func getFBNativeAd(placementId: String, xbPlacement: String, type: String, price: Double) -> (Bool,  Any?, SDKGroupItem?)
    func getGoogleNativeAd(placementId: String, xbPlacement: String, type: String, price: Double) -> (Bool, Any?, SDKGroupItem?)
    func getDUNativeAd(placementId: String, xbPlacement: String, type: String, price: Double) -> (Bool,  Any?, SDKGroupItem?)
    func getAppnextNativeAd(placementId: String, xbPlacement: String, type: String, price: Double) -> (Bool,  Any?, SDKGroupItem?)
    func getMTGNativeAd(placementId: String, xbPlacement: String, type: String, price: Double) -> (Bool,  Any?, SDKGroupItem?)
    
    func getFBNativeAdView(ad: Any) -> XBNativeAdBaseView
    func getGoogleNativeAdView(ad: Any) -> XBNativeAdBaseView
    func getDUNativeAdView(ad: Any) -> XBNativeAdBaseView
    func getAppnextNativeAdView(ad: Any) -> XBNativeAdBaseView
    func getMTGNativeAdView(ad: Any) -> XBNativeAdBaseView
    
    func getFBNativeAdSView(ad: Any) -> XBNativeAdBaseView
    func getGoogleNativeAdSView(ad: Any) -> XBNativeAdBaseView
    func getDUNativeAdSView(ad: Any) -> XBNativeAdBaseView
    func getAppnextNativeAdSView(ad: Any) -> XBNativeAdBaseView
    func getMTGNativeAdSView(ad: Any) -> XBNativeAdBaseView
}
extension AdapterNativeAdDelegate {
    func getFBNativeAd(placementId: String, xbPlacement: String, type: String, price: Double) -> (Bool,  Any?, SDKGroupItem?) {return (false, nil, nil)}
    func getGoogleNativeAd(placementId: String, xbPlacement: String, type: String, price: Double) -> (Bool, Any?, SDKGroupItem?) {return (false, nil, nil)}
    func getDUNativeAd(placementId: String, xbPlacement: String, type: String, price: Double) -> (Bool,  Any?, SDKGroupItem?) {return (false, nil, nil)}
    func getAppnextNativeAd(placementId: String, xbPlacement: String, type: String, price: Double) -> (Bool,  Any?, SDKGroupItem?) {return (false, nil, nil)}
    func getMTGNativeAd(placementId: String, xbPlacement: String, type: String, price: Double) -> (Bool,  Any?, SDKGroupItem?) {return (false, nil, nil)}
    
    func getFBNativeAdView(ad: Any) -> XBNativeAdBaseView {return XBNativeAdBaseView()}
    func getGoogleNativeAdView(ad: Any) -> XBNativeAdBaseView {return XBNativeAdBaseView()}
    func getDUNativeAdView(ad: Any) -> XBNativeAdBaseView {return XBNativeAdBaseView()}
    func getAppnextNativeAdView(ad: Any) -> XBNativeAdBaseView {return XBNativeAdBaseView()}
    func getMTGNativeAdView(ad: Any) -> XBNativeAdBaseView {return XBNativeAdBaseView()}
    
    func getFBNativeAdSView(ad: Any) -> XBNativeAdBaseView {return XBNativeAdBaseView()}
    func getGoogleNativeAdSView(ad: Any) -> XBNativeAdBaseView {return XBNativeAdBaseView()}
    func getDUNativeAdSView(ad: Any) -> XBNativeAdBaseView {return XBNativeAdBaseView()}
    func getAppnextNativeAdSView(ad: Any) -> XBNativeAdBaseView {return XBNativeAdBaseView()}
    func getMTGNativeAdSView(ad: Any) -> XBNativeAdBaseView {return XBNativeAdBaseView()}
}

class XbAdAdapter: NSObject, AdapterNativeAdDelegate {
   
    static let shared = XbAdAdapter()
    func getNativeAd(source: String, placementId: String, xbPlacement: String, type: String, price: Double) -> (Bool, Any?, SDKGroupItem?) {
        
        switch source {
        case "facebook":
            return getFBNativeAd(placementId: placementId, xbPlacement: xbPlacement, type: type, price: price)
        case "admob":
            return getGoogleNativeAd(placementId: placementId, xbPlacement: xbPlacement, type: type, price: price)
        case "baidu":
           return  getDUNativeAd(placementId: placementId, xbPlacement: xbPlacement, type: type, price: price)
        case "appnext":
            return getAppnextNativeAd(placementId: placementId, xbPlacement: xbPlacement, type: type, price: price)
        case "mintegral":
            return getMTGNativeAd(placementId: placementId, xbPlacement: xbPlacement, type: type, price: price)
        default:
            return (false, nil, nil)
        }
    }
    enum NativeAdViewType: String {
        case big
        case small
    }
    func getNativeAdView(source: String, type: NativeAdViewType, ad: Any) -> XBNativeAdBaseView {
        switch source {
        case "facebook":
            if type == .small {
                return getFBNativeAdSView(ad: ad)
            } else {
                return getFBNativeAdView(ad: ad)
            }
        case "admob":
            if type == .small {
                return getGoogleNativeAdSView(ad: ad)
            } else {
                return getGoogleNativeAdView(ad: ad)
            }
            
        case "baidu":
            if type == .small {
                return getDUNativeAdSView(ad: ad)
            } else {
                return getDUNativeAdView(ad: ad)
            }
           
        case "appnext":
            if type == .small {
                return getAppnextNativeAdSView(ad: ad)
            } else {
                return getAppnextNativeAdView(ad: ad)
            }
            
        case "mintegral":
            if type == .small {
                return getMTGNativeAdSView(ad: ad)
            } else {
                return getMTGNativeAdView(ad: ad)
            }
            
        default:
            return XBNativeAdBaseView()
        }
        
    }
}

protocol XbNativeAdlogDelegate: class {
    func onNativeAdClick(title: String?, desc: String?)
    func onNativeAdImp()
}
class XBNativeAdBaseView: UIView {
    var haveCallbackImp: Bool = false
    var logDelegate: XbNativeAdlogDelegate?
}
