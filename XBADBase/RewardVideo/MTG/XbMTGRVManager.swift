//
//  XBRewardVideoManager_MTG.swift
//  XBADBaseDemo
//
//  Created by 全尼古拉斯 on 2020/3/30.
//  Copyright © 2020 全尼古拉斯. All rights reserved.
//

import Foundation
import GoogleMobileAds

class XbMTGRVManager: NSObject, RVAdDelegate {

    static let shared = XbMTGRVManager()
    // 聚合缓存
    var mtgRewardVideoDownLoader: MTGRewardVideoDownLoader?
    // 非聚合
    var weakMTGRewardAdLoadDelegate: XBWeakMTGRewardAdLoadDelegate?
    var weakMTGRewardAdShowDelegate: XBWeakMTGRewardAdShowDelegate?
    
    var actionCallback: ((XbRVAction, String?) -> ())?
    // 请求缓存FB广告
    func onCacheRVAd(placement: String, frequencyControl: FrequencyControl?, price: Double, complete: ((String, RewardVideoModel?, cacheResult, Int?)->())?) {
        let startTime = Date().timeIntervalSince1970
        mtgRewardVideoDownLoader = MTGRewardVideoDownLoader()
        mtgRewardVideoDownLoader!.cacheCallBack = { (code, msg, model) in
            complete?(model.placement, model, (code, msg, Date().timeIntervalSince1970 - startTime), nil)
        }
        mtgRewardVideoDownLoader!.cacheMTGAd(placementId: placement, price: price)
    }
    
    func checkTimeout(rvAd: Any, placement: String?) -> Bool {
        var isTimeout = true
        if let rv = rvAd as? MTGRewardAdManager  {
            if rv.isVideoReady(toPlay: placement ?? "") {
                isTimeout = false
            }
        }
        return isTimeout
    }
    
    func showRV(rv: Any, placement: String, callback: ((Bool) -> ())? = nil, actionCallback: ((XbRVAction, String?) -> ())?) {
        guard let mtgRewardedVideoAd = rv as? MTGRewardAdManager, mtgRewardedVideoAd.isVideoReady(toPlay: placement) else {
            callback?(false)
            return
        }
        weakMTGRewardAdShowDelegate = XBWeakMTGRewardAdShowDelegate.init(mtgRewardAdShowDelegate: self)
        mtgRewardedVideoAd.showVideo(placement, withRewardId: "1", userId: nil, delegate: weakMTGRewardAdShowDelegate, viewController: Utils.AppTopViewController()!)
        callback?(true)
        self.actionCallback = actionCallback
    }
    
    func setupRVAd(placement: String, actionCallback: ((XbRVAction, String?) -> ())?) {        weakMTGRewardAdLoadDelegate = XBWeakMTGRewardAdLoadDelegate.init(mtgRewardAdLoadDelegate: self)
        MTGRewardAdManager.sharedInstance().loadVideo(placement, delegate: weakMTGRewardAdLoadDelegate)
        self.actionCallback = actionCallback
    }
}

extension XbMTGRVManager: MTGRewardAdLoadDelegate, MTGRewardAdShowDelegate {
    
    func onVideoAdLoadSuccess(_ unitId: String?) {
//        self.clearWaitNotice()
//        let nowTime = Date().timeIntervalSince1970 * 1000
//        setLog(action: "loading", nowTime: nowTime, startTime: startTime, success: true, reason: 0, msg: "")
//        startTime = nowTime
        if unitId != nil, MTGRewardAdManager.sharedInstance().isVideoReady(toPlay: unitId!) {
            weakMTGRewardAdShowDelegate = XBWeakMTGRewardAdShowDelegate.init(mtgRewardAdShowDelegate: self)
            MTGRewardAdManager.sharedInstance().showVideo(unitId!, withRewardId: "1", userId: nil, delegate: weakMTGRewardAdShowDelegate, viewController: Utils.AppTopViewController()!)
//            // StatisticsEvent.logEvent(statisticsName: StatisticsName.REWARD_VIDEO_MTG_PLAY_SUCCEED, trigDic: ["from": from])
            actionCallback?(.load, nil)
        } else {
//            // StatisticsEvent.logEvent(statisticsName: StatisticsName.REWARD_VIDEO_MTG_PLAY_FAILED, trigDic: ["from": from])
//            self.dismiss(animated: false, completion: nil)
            actionCallback?(.load, "not valid")
        }
    }
    func onVideoAdLoadFailed(_ unitId: String?, error: Error) {
//        // StatisticsEvent.logEvent(statisticsName: StatisticsName.REWARD_VIDEO_MTG_PLAY_FAILED, trigDic: ["from": from])
//        rewardVideoAdFail(msg: error.localizedDescription)
        actionCallback?(.load, error.localizedDescription)
    }
    func onVideoAdShowSuccess(_ unitId: String?) {
//        logImp()
        actionCallback?(.imp, nil)
    }
    func onVideoAdShowFailed(_ unitId: String?, withError error: Error) {
//        // StatisticsEvent.logEvent(statisticsName: StatisticsName.REWARD_VIDEO_MTG_PLAY_FAILED, trigDic: ["from": from])
//        rewardVideoAdFail(msg: error.localizedDescription)
        actionCallback?(.load, error.localizedDescription)
    }
    
    func onVideoAdDismissed(_ unitId: String?, withConverted converted: Bool, withRewardInfo rewardInfo: MTGRewardAdInfo?) {
//        hasCompleteVideo = rewardInfo != nil
        if rewardInfo == nil {
//            // StatisticsEvent.logEvent(statisticsName: StatisticsName.REWARD_VIDEO_MTG_PLAY_NOT_COMPLETE, trigDic: ["from": from])
        } else {
            actionCallback?(.playDone, nil)
        }
        
        DelayTimer.delay(1, task: {
//            self.fetchRewardOnComplete()
            self.actionCallback?(.close, nil)
        })
    }
   
    func onVideoAdClicked(_ unitId: String?) {
//        onClickAdvert(title: nil, desc: nil)
        actionCallback?(.click, nil)
    }
}

