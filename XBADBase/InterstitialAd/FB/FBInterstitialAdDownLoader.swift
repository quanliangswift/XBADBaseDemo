//
//  FBInterstitialAdDownLoader.swift
//  TopNews
//
//  Created by xb on 2019/5/28.
//  Copyright © 2019 xb. All rights reserved.
//

import UIKit
import FBAudienceNetwork

class FBInterstitialAdDownLoader: NSObject, FBInterstitialAdDelegate {
    deinit {
        let className = NSStringFromClass(self.classForCoder)
        print("\n\n---------deinit:\(className)---------\n\n")
    }
    
    
    var cacheCallBack: ((_ errorCode: Int, _ msg:  String, _ placementID:  String, _ model:  InterstitialAdModel)->())?
    
    var adModel = InterstitialAdModel()
    var interstitialAd: FBInterstitialAd?
    func cacheFBAd(placementId: String, id: String, from: String, price: Double) {
        adModel.id = id
        adModel.placement = placementId
        adModel.source = InterstitialAdType.facebook.rawValue
        adModel.from = from
        adModel.price = price

        interstitialAd = FBInterstitialAd.init(placementID: placementId)
        interstitialAd?.delegate = self
        interstitialAd?.load()
    }
    
    func interstitialAdDidLoad(_ interstitialAd: FBInterstitialAd) {
        if interstitialAd.isAdValid {
            adModel.interstitialAd = interstitialAd
            cacheCallBack?(0, "", interstitialAd.placementID, adModel)
        } else {
            cacheCallBack?(1, "", interstitialAd.placementID, adModel)
        }
        
    }
    func interstitialAd(_ interstitialAd: FBInterstitialAd, didFailWithError error: Error) {
        cacheCallBack?((error as NSError).code, error.localizedDescription,  interstitialAd.placementID, adModel)
    }
}
