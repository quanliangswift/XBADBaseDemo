//
//  XbGoogleInterstitialManager.swift
//  XBADBaseDemo
//
//  Created by 全尼古拉斯 on 2020/4/1.
//  Copyright © 2020 全尼古拉斯. All rights reserved.
//

import Foundation
import GoogleMobileAds
class XbGoogleInterstitialManager: NSObject, InterstitialAdDelegate {
    static let shared = XbGoogleInterstitialManager()
    var googleInterstitialDownLoader: [String: GoogleInterstitialAdDownLoader] = [:]
    var closeCallback: (()->())?
    func onCacheInterstitialAd(placement: String, id: String, from: String, callback: @escaping ((Int, String, String, InterstitialAdModel) -> ())) {
        let downLoader = GoogleInterstitialAdDownLoader()
        downLoader.cacheCallBack = { (errorCode, msg, placementID, model) in
            callback(errorCode, msg, placementID, model)
            self.googleInterstitialDownLoader[id] = nil
        }
        downLoader.cacheGoogleAd(placementId: placement, id: id, from: from, price: 0)
        googleInterstitialDownLoader[id] = downLoader
    }
    
    func showInterstitialAd(model: InterstitialAdModel, adId: String, adDic: [String: Any], callback: @escaping ((Int, String, String, [String : Any]) -> Void), closeCallback: (()->())?) {
        self.closeCallback = closeCallback
        if let ad = model.interstitialAd as? DFPInterstitial {
            ad.delegate = self
            if ad.isReady, let vc = Utils.AppTopViewController() {
                ad.present(fromRootViewController: vc)
                model.startShow = Date().timeIntervalSince1970
                callback(0, "", adId, adDic)
                return
            }
            callback(1003, "", adId, adDic)
            return
        }
        callback(1002, "", adId, adDic)
    }
}
extension XbGoogleInterstitialManager: GADInterstitialDelegate {
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        closeCallback?()
    }
}
