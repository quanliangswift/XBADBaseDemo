//
//  XbALInterstitialManager.swift
//  XBADBaseDemo
//
//  Created by 全尼古拉斯 on 2020/4/1.
//  Copyright © 2020 全尼古拉斯. All rights reserved.
//

import Foundation
import AppLovinSDK
class XbALInterstitialManager: NSObject, InterstitialAdDelegate {
    static let shared = XbALInterstitialManager()
    var alInterstitialDownLoader: [String: ALInterstitialAdDownLoader] = [:]
    var closeCallback: (()->())?
    func onCacheInterstitialAd(placement: String, id: String, from: String, callback: @escaping ((Int, String, String, InterstitialAdModel) -> ())) {
        let downLoader = ALInterstitialAdDownLoader()
        downLoader.cacheCallBack = { (errorCode, msg, placementID, model) in
            callback(errorCode, msg, placementID, model)
            self.alInterstitialDownLoader[id] = nil
        }
        downLoader.cacheALAd(placementId: placement, id: id, from: from, price: 0)
        alInterstitialDownLoader[id] = downLoader
    }
    
    func showInterstitialAd(model: InterstitialAdModel, adId: String, adDic: [String: Any], callback: @escaping ((Int, String, String, [String : Any]) -> Void), closeCallback: (()->())?) {
        self.closeCallback = closeCallback
        if let ad = model.interstitialAd as? ALAd {
            ALInterstitialAd.shared().adDisplayDelegate = self
            ALInterstitialAd.shared().adVideoPlaybackDelegate = self
            ALInterstitialAd.shared().show(ad)
            model.startShow = Date().timeIntervalSince1970
            callback(0, "", adId, adDic)
            return
            
        }
        callback(1002, "", adId, adDic)
    }
}
extension XbALInterstitialManager: ALAdDisplayDelegate, ALAdVideoPlaybackDelegate {
    func ad(_ ad: ALAd, wasDisplayedIn view: UIView) {
    }
    
    func ad(_ ad: ALAd, wasHiddenIn view: UIView) {
        closeCallback?()
    }
    
    func ad(_ ad: ALAd, wasClickedIn view: UIView) {
    }
    
    func videoPlaybackBegan(in ad: ALAd) {
    }
    
    func videoPlaybackEnded(in ad: ALAd, atPlaybackPercent percentPlayed: NSNumber, fullyWatched wasFullyWatched: Bool) {
    }
}
