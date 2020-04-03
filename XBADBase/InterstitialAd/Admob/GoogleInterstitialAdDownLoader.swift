//
//  GoogleInterstitialAdDownLoader.swift
//  TopNews_SV
//
//  Created by xb on 2019/8/8.
//  Copyright © 2019 xb. All rights reserved.
//

import UIKit
import GoogleMobileAds
class GoogleInterstitialAdDownLoader: NSObject, GADInterstitialDelegate {
    deinit {
        let className = NSStringFromClass(self.classForCoder)
        print("\n\n---------deinit:\(className)---------\n\n")
    }
    
    
    var cacheCallBack: ((_ errorCode: Int, _ msg:  String, _ placementID:  String, _ model:  InterstitialAdModel)->())?
    
    var adModel = InterstitialAdModel()
    var interstitial: DFPInterstitial?
    
    func cacheGoogleAd(placementId: String, id: String, from: String, price: Double) {
        adModel.id = id
        adModel.placement = placementId
        adModel.source = InterstitialAdType.admob.rawValue
        adModel.from = from
        adModel.price = price
        interstitial = DFPInterstitial(adUnitID: placementId)
        interstitial!.delegate = self
        let request = DFPRequest()
        interstitial?.load(request)
        
    }
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("interstitialDidReceiveAd")
        
        if interstitial?.isReady ?? false {
            adModel.interstitialAd = interstitial
            cacheCallBack?(0, "", ad.adUnitID ?? "", adModel)
        } else {
            cacheCallBack?(1, "", ad.adUnitID ?? "", adModel)
        }
    }
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        cacheCallBack?((error as NSError).code, error.localizedDescription,  interstitial?.adUnitID ?? "", adModel)
        print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
}
