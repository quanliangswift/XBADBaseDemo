//
//  XBRewardVideoManager_admob.swift
//  XBADBaseDemo
//
//  Created by 全尼古拉斯 on 2020/3/30.
//  Copyright © 2020 全尼古拉斯. All rights reserved.
//

import Foundation
import GoogleMobileAds

class XbGoogleRVManager: NSObject, RVAdDelegate {


    static let shared = XbGoogleRVManager()
    
    var googleRewardVideoDownLoader: GoogleRewardVideoDownLoader?
    
    var actionCallback: ((XbRVAction, String?) -> ())?
    // 请求缓存FB广告
    func onCacheRVAd(placement: String, frequencyControl: FrequencyControl?, price: Double, complete: ((String, RewardVideoModel?, cacheResult, Int?)->())?) {
        let startTime = Date().timeIntervalSince1970
        googleRewardVideoDownLoader = GoogleRewardVideoDownLoader()
        googleRewardVideoDownLoader!.cacheCallBack = { (code, msg, model) in
            complete?(model.placement, model, (code, msg, Date().timeIntervalSince1970 - startTime), nil)
        }
        googleRewardVideoDownLoader!.cacheGoogleAd(placementId: placement, price: price)
    }
    
    
    func checkTimeout(rvAd: Any, placement: String?) -> Bool {
        var isTimeout = true
        if let rv = rvAd as? GADRewardBasedVideoAd  {
            if rv.isReady {
                isTimeout = false
            }
        }
        return isTimeout
    }
    
    func showRV(rv: Any, placement: String, callback: ((Bool) -> ())? = nil, actionCallback: ((XbRVAction, String?) -> ())?) {
        guard let googleRewardedVideoAd = rv as? GADRewardBasedVideoAd, googleRewardedVideoAd.isReady else {
            callback?(false)
            return
        }
        googleRewardedVideoAd.delegate = self
        googleRewardedVideoAd.present(fromRootViewController: Utils.AppTopViewController()!)
        callback?(true)
        self.actionCallback = actionCallback
    }
   
    func setupRVAd(placement: String, actionCallback: ((XbRVAction, String?) -> ())?) {
        GADRewardBasedVideoAd.sharedInstance().delegate = self
        print(placement)
        GADRewardBasedVideoAd.sharedInstance().load(GADRequest(),withAdUnitID: placement)
        self.actionCallback = actionCallback
    }
}
extension XbGoogleRVManager: GADRewardBasedVideoAdDelegate{
        
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didRewardUserWith reward: GADAdReward) {
//        hasCompleteVideo = true
        actionCallback?(.playDone, nil)
        print("1-----Reward received with currency: \(reward.type), amount \(reward.amount).")
    }
    func rewardBasedVideoAdDidReceive(_ rewardBasedVideoAd:GADRewardBasedVideoAd) {
        print("2-----Reward based video ad is received.")
//        self.clearWaitNotice()
//        let nowTime = Date().timeIntervalSince1970 * 1000
//        setLog(action: "loading", nowTime: nowTime, startTime: startTime, success: true, reason: 0, msg: "")
//        startTime = nowTime
        if GADRewardBasedVideoAd.sharedInstance().isReady == true {
            GADRewardBasedVideoAd.sharedInstance().present(fromRootViewController: Utils.AppTopViewController()!)
//            // StatisticsEvent.logEvent(statisticsName: StatisticsName.REWARD_VIDEO_ADMOB_PLAY_SUCCEED, trigDic: ["from": from])
            actionCallback?(.load, nil)
        } else {
//            // StatisticsEvent.logEvent(statisticsName: StatisticsName.REWARD_VIDEO_ADMOB_PLAY_FAILED, trigDic: ["from": from])
//            self.dismiss(animated: false, completion: nil)
            actionCallback?(.load, "not valid")
        }
    }
    
    func rewardBasedVideoAdDidOpen(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("3-----Opened reward based video ad.")
//        startTime = Date().timeIntervalSince1970 * 1000
//        logImp()
        actionCallback?(.imp, nil)
    }
    
    func rewardBasedVideoAdDidStartPlaying(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("4-----Reward based video ad started playing.")
    }
    
    func rewardBasedVideoAdDidCompletePlaying(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("5-----Reward based video ad has completed.")
    }
    
    func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("6-----Reward based video ad is closed.")
//        if !hasCompleteVideo {
//            // StatisticsEvent.logEvent(statisticsName: StatisticsName.REWARD_VIDEO_ADMOB_PLAY_NOT_COMPLETE, trigDic: ["from": from])
//        }
//        fetchRewardOnComplete()
        actionCallback?(.close, nil)
    }
    
    func rewardBasedVideoAdWillLeaveApplication(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("7-----Reward based video ad will leave application.")
//        onClickAdvert(title: nil, desc: nil)
        actionCallback?(.click, nil)
    }
    
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didFailToLoadWithError error: Error) {
//        // StatisticsEvent.logEvent(statisticsName: StatisticsName.REWARD_VIDEO_ADMOB_PLAY_FAILED, trigDic: ["from": from])
//        rewardVideoAdFail(msg: error.localizedDescription)
        print("8-----Reward based video ad failed to load.",error)
        actionCallback?(.load, error.localizedDescription)
    }
    
}

