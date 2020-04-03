//
//  File.swift
//  XBADBaseDemo
//
//  Created by 全尼古拉斯 on 2020/4/1.
//  Copyright © 2020 全尼古拉斯. All rights reserved.
//

import Foundation
import FBAudienceNetwork
class XbFbInterstitialManager: NSObject, InterstitialAdDelegate {
    static let shared = XbFbInterstitialManager()
    var fbInterstitialDownLoader: [String: FBInterstitialAdDownLoader] = [:]
    var closeCallback: (()->())?
    func onCacheInterstitialAd(placement: String, id: String, from: String, callback: @escaping ((Int, String, String, InterstitialAdModel) -> ())) {
        let downLoader = FBInterstitialAdDownLoader()
        downLoader.cacheCallBack = { (errorCode, msg, placementID, model) in
            callback(errorCode, msg, placementID, model)
            self.fbInterstitialDownLoader[id] = nil
        }
        downLoader.cacheFBAd(placementId: placement, id: id, from: from, price: 0)
        fbInterstitialDownLoader[id] = downLoader
    }
    
    func showInterstitialAd(model: InterstitialAdModel, adId: String, adDic: [String: Any], callback: @escaping ((Int, String, String, [String : Any]) -> Void), closeCallback: (()->())?) {
        self.closeCallback = closeCallback
        if let ad = model.interstitialAd as? FBInterstitialAd {
            ad.delegate = self
            if ad.isAdValid {
                ad.show(fromRootViewController: Utils.AppTopViewController())
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
extension XbFbInterstitialManager: FBInterstitialAdDelegate {
    func interstitialAdDidClose(_ interstitialAd: FBInterstitialAd) {
//        didCloseLog()
        closeCallback?()
    }
}
