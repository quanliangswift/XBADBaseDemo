//
//  GoogleRewardVideoDownLoader.swift
//  TopNews_SV
//
//  Created by 全尼古拉斯 on 2019/9/20.
//  Copyright © 2019 xb. All rights reserved.
//

import UIKit
import GoogleMobileAds
class GoogleRewardVideoDownLoader: NSObject, GADRewardBasedVideoAdDelegate {
    
    
    deinit {
        let className = NSStringFromClass(self.classForCoder)
        print("\n\n---------deinit:\(className)---------\n\n")
    }
    
    
    var cacheCallBack: ((_ errorCode: Int, _ msg:  String, _ model:  RewardVideoModel)->())?
    
    var adModel = RewardVideoModel()
    func cacheGoogleAd(placementId: String, price: Double) {
        GADRewardBasedVideoAd.sharedInstance().delegate = self
        print(placementId)
        adModel.placement = placementId
        adModel.source = "admob"
        adModel.price = price
        if GADRewardBasedVideoAd.sharedInstance().isReady == false {
            GADRewardBasedVideoAd.sharedInstance().load(GADRequest(),withAdUnitID: placementId)
        }
    }
    func rewardBasedVideoAdDidReceive(_ rewardBasedVideoAd:GADRewardBasedVideoAd) {
        if GADRewardBasedVideoAd.sharedInstance().isReady == true {
            adModel.rvAd = GADRewardBasedVideoAd.sharedInstance()
            cacheCallBack?(0, "", adModel)
        } else {
            cacheCallBack?(1, "", adModel)
        }
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didFailToLoadWithError error: Error) {
        cacheCallBack?((error as NSError).code, error.localizedDescription, adModel)
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didRewardUserWith reward: GADAdReward) {
    }
}
