//
//  FBRewardVideoDownLoader.swift
//  TopNews_SV
//
//  Created by 全尼古拉斯 on 2019/9/20.
//  Copyright © 2019 xb. All rights reserved.
//

import UIKit
import FBAudienceNetwork
class FBRewardVideoDownLoader: NSObject, FBRewardedVideoAdDelegate {
    deinit {
        let className = NSStringFromClass(self.classForCoder)
        print("\n\n---------deinit:\(className)---------\n\n")
    }
    
    
    var cacheCallBack: ((_ errorCode: Int, _ msg:  String, _ model:  RewardVideoModel)->())?
    
    var adModel = RewardVideoModel()
    var fbRewardedVideoAd: FBRewardedVideoAd?
    func cacheFBAd(placementId: String, price: Double) {
        fbRewardedVideoAd = FBRewardedVideoAd.init(placementID: placementId)
        fbRewardedVideoAd!.delegate = self
        fbRewardedVideoAd!.load()
        adModel.placement = placementId
        adModel.source = "facebook"
        adModel.price = price
    }
    func rewardedVideoAdDidLoad(_ rewardedVideoAd: FBRewardedVideoAd) {
        if rewardedVideoAd.isAdValid {
            adModel.rvAd = rewardedVideoAd
            cacheCallBack?(0, "", adModel)
        } else {
            cacheCallBack?(1, "", adModel)
        }
    }
    
    func rewardedVideoAd(_ rewardedVideoAd: FBRewardedVideoAd, didFailWithError error: Error) {
        cacheCallBack?((error as NSError).code, error.localizedDescription, adModel)
    }
 
}
