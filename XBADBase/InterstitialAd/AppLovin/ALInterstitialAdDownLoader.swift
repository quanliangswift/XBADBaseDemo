//
//  ALInterstitialAdDownLoader.swift
//  TopNews_SV
//
//  Created by 全尼古拉斯 on 2019/12/9.
//  Copyright © 2019 xb. All rights reserved.
//

import UIKit
import AppLovinSDK
class ALInterstitialAdDownLoader: NSObject, ALAdLoadDelegate {
    deinit {
        let className = NSStringFromClass(self.classForCoder)
        print("\n\n---------deinit:\(className)---------\n\n")
    }
    
    
    var cacheCallBack: ((_ errorCode: Int, _ msg:  String, _ placementID:  String, _ model:  InterstitialAdModel)->())?
    
    var adModel = InterstitialAdModel()
    
    func cacheALAd(placementId: String, id: String, from: String, price: Double) {
        adModel.id = id
        adModel.placement = placementId
        adModel.source = InterstitialAdType.applovin.rawValue
        adModel.from = from
        adModel.price = price

        ALSdk.shared()?.adService.loadNextAd(ALAdSize.interstitial, andNotify: self)
        
    }
    
    func adService(_ adService: ALAdService, didLoad ad: ALAd) {
        adModel.interstitialAd = ad
        cacheCallBack?(0, "", adModel.placement, adModel)
    }
    func adService(_ adService: ALAdService, didFailToLoadAdWithError code: Int32) {
        cacheCallBack?(Int(code), "",  adModel.placement, adModel)
    }
    
}
