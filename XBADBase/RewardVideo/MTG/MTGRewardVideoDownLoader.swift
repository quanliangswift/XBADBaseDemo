//
//  MTGRewardVideoDownLoader.swift
//  TopNews_SV
//
//  Created by 全尼古拉斯 on 2019/9/20.
//  Copyright © 2019 xb. All rights reserved.
//

import UIKit

class MTGRewardVideoDownLoader: NSObject, MTGRewardAdLoadDelegate {
    deinit {
        let className = NSStringFromClass(self.classForCoder)
        print("\n\n---------deinit:\(className)---------\n\n")
    }
    
    var cacheCallBack: ((_ errorCode: Int, _ msg:  String, _ model:  RewardVideoModel)->())?
    
    var adModel = RewardVideoModel()
    var weakMTGRewardAdLoadDelegate: XBWeakMTGRewardAdLoadDelegate?
    
    func cacheMTGAd(placementId: String,  price: Double) {
        weakMTGRewardAdLoadDelegate = XBWeakMTGRewardAdLoadDelegate.init(mtgRewardAdLoadDelegate: self)
        MTGRewardAdManager.sharedInstance().loadVideo(placementId, delegate: weakMTGRewardAdLoadDelegate)
        adModel.placement = placementId
        adModel.source = "mintegral"
        adModel.price = price
    }
    func onVideoAdLoadSuccess(_ unitId: String?) {
        if unitId != nil, MTGRewardAdManager.sharedInstance().isVideoReady(toPlay: unitId!) {
            adModel.rvAd = MTGRewardAdManager.sharedInstance()
            cacheCallBack?(0, "", adModel)
        } else {
            cacheCallBack?(1, "", adModel)
        }
    }
    
    func onVideoAdLoadFailed(_ unitId: String?, error: Error) {
        cacheCallBack?((error as NSError).code, error.localizedDescription, adModel)
    }
}
