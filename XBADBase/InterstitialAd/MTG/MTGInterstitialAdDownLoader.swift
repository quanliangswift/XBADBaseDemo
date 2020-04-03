//
//  MTGInterstitialAdDownLoader.swift
//  TopNews_SV
//
//  Created by 全尼古拉斯 on 2019/9/3.
//  Copyright © 2019 xb. All rights reserved.
//

import UIKit

class MTGInterstitialAdDownLoader: NSObject, MTGInterstitialVideoDelegate {
    deinit {
        let className = NSStringFromClass(self.classForCoder)
        print("\n\n---------deinit:\(className)---------\n\n")
    }
    
    
    var cacheCallBack: ((_ errorCode: Int, _ msg:  String, _ placementID:  String, _ model:  InterstitialAdModel)->())?
    
    var adModel = InterstitialAdModel()
    var ivAdManager: MTGInterstitialVideoAdManager?
    func cacheMTGAd(placementId: String, id: String, from: String, price: Double) {
        adModel.id = id
        adModel.placement = placementId
        adModel.source = InterstitialAdType.mintegral.rawValue
        adModel.from = from
        adModel.price = price
        ivAdManager = MTGInterstitialVideoAdManager.init(unitID: placementId, delegate: self)
        ivAdManager?.delegate = self
        ivAdManager?.loadAd()
    }
    
    func onInterstitialVideoLoadSuccess(_ adManager: MTGInterstitialVideoAdManager) {
        if adManager.isVideoReady(toPlay: adManager.currentUnitId) {
            adModel.interstitialAd = adManager
            cacheCallBack?(0, "", adManager.currentUnitId, adModel)
        } else {
            cacheCallBack?(1, "", adManager.currentUnitId, adModel)
        }
    }
    
    func onInterstitialVideoLoadFail(_ error: Error, adManager: MTGInterstitialVideoAdManager) {
        cacheCallBack?((error as NSError).code, error.localizedDescription, adManager.currentUnitId, adModel)
    }
}

