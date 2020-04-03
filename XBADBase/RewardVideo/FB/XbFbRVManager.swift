//
//  File.swift
//  XBADBaseDemo
//
//  Created by 全尼古拉斯 on 2020/3/30.
//  Copyright © 2020 全尼古拉斯. All rights reserved.
//

import Foundation
import FBAudienceNetwork

class XbFbRVManager: NSObject, RVAdDelegate {

    static let shared = XbFbRVManager()
    
    var fbRewardVideoDownLoader: FBRewardVideoDownLoader?
    
    var fbRewardedVideoAd: FBRewardedVideoAd?
    var actionCallback: ((XbRVAction, String?) -> ())?
    
    // 请求缓存FB广告
    func onCacheRVAd(placement: String, frequencyControl: FrequencyControl?, price: Double, complete: ((String, RewardVideoModel?, cacheResult, Int?)->())?) {
        let startTime = Date().timeIntervalSince1970
        fbRewardVideoDownLoader = FBRewardVideoDownLoader()
        fbRewardVideoDownLoader!.cacheCallBack = { (code, msg, model) in
            complete?(model.placement, model, (code, msg, Date().timeIntervalSince1970 - startTime), nil)
            self.fbRewardVideoDownLoader = nil
        }
        fbRewardVideoDownLoader!.cacheFBAd(placementId: placement, price: price)
    }
    
    func checkTimeout(rvAd: Any, placement: String?) -> Bool {
        var isTimeout = true
        if let rv = rvAd as? FBRewardedVideoAd  {
            if rv.isAdValid {
                isTimeout = false
            }
        }
        return isTimeout
    }
    
    func showRV(rv: Any, placement: String, callback: ((Bool) -> ())? = nil, actionCallback: ((XbRVAction, String?) -> ())?) {
        guard let fbRewardedVideoAd = rv as? FBRewardedVideoAd, fbRewardedVideoAd.isAdValid else {
            callback?(false)
            return
        }
        fbRewardedVideoAd.delegate = self
        fbRewardedVideoAd.show(fromRootViewController: Utils.AppTopViewController()!, animated: true)
        callback?(true)
        self.actionCallback = actionCallback
    }
    
    func setupRVAd(placement: String, actionCallback: ((XbRVAction, String?) -> ())?) {
        self.fbRewardedVideoAd = FBRewardedVideoAd.init(placementID: placement)
        self.fbRewardedVideoAd?.delegate = self
        self.fbRewardedVideoAd?.load()
        self.actionCallback = actionCallback
    }
    
}

extension XbFbRVManager: FBRewardedVideoAdDelegate {
    func rewardedVideoAdWillLogImpression(_ rewardedVideoAd: FBRewardedVideoAd) {
        actionCallback?(.imp, nil)
    }
    
    func rewardedVideoAdVideoComplete(_ rewardedVideoAd: FBRewardedVideoAd) {
        actionCallback?(.playDone, nil)
    }
    func rewardedVideoAdDidLoad(_ rewardedVideoAd: FBRewardedVideoAd) {
        if self.fbRewardedVideoAd?.isAdValid ?? false {
            self.fbRewardedVideoAd?.delegate = self
            self.fbRewardedVideoAd?.show(fromRootViewController: Utils.AppTopViewController()!, animated: true)
            actionCallback?(.load, nil)
        } else {
            actionCallback?(.load, "not valid")
        }
    }
    
    func rewardedVideoAdDidClose(_ rewardedVideoAd: FBRewardedVideoAd) {
        actionCallback?(.close, nil)
    }
    func rewardedVideoAdDidClick(_ rewardedVideoAd: FBRewardedVideoAd) {
        actionCallback?(.click, nil)
    }
    func rewardedVideoAd(_ rewardedVideoAd: FBRewardedVideoAd, didFailWithError error: Error) {
        actionCallback?(.load, error.localizedDescription)
    }
    
}
