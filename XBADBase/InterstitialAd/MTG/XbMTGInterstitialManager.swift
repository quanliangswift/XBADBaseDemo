//
//  XbMTGInterstitialManager.swift
//  XBADBaseDemo
//
//  Created by 全尼古拉斯 on 2020/4/1.
//  Copyright © 2020 全尼古拉斯. All rights reserved.
//

import Foundation
class XbMTGInterstitialManager: NSObject, InterstitialAdDelegate {
    static let shared = XbMTGInterstitialManager()
    var mtgInterstitialDownLoader: [String: MTGInterstitialAdDownLoader] = [:]
    var closeCallback: (()->())?
    func onCacheInterstitialAd(placement: String, id: String, from: String, callback: @escaping ((Int, String, String, InterstitialAdModel) -> ())) {
        let downLoader = MTGInterstitialAdDownLoader()
        downLoader.cacheCallBack = { (errorCode, msg, placementID, model) in
            callback(errorCode, msg, placementID, model)
            self.mtgInterstitialDownLoader[id] = nil
        }
        downLoader.cacheMTGAd(placementId: placement, id: id, from: from, price: 0)
        mtgInterstitialDownLoader[id] = downLoader
    }
    
    func showInterstitialAd(model: InterstitialAdModel, adId: String, adDic: [String: Any], callback: @escaping ((Int, String, String, [String : Any]) -> Void), closeCallback: (()->())?) {
        self.closeCallback = closeCallback
        if let ad = model.interstitialAd as? MTGInterstitialVideoAdManager {
            ad.delegate = self
            if ad.isVideoReady(toPlay: ad.currentUnitId), let vc = Utils.AppTopViewController() {
                ad.show(from: vc)
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
extension XbMTGInterstitialManager: MTGInterstitialVideoDelegate {
    func onInterstitialVideoAdDismissed(withConverted converted: Bool, adManager: MTGInterstitialVideoAdManager) {
        closeCallback?()
    }
}
