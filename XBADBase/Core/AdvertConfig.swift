//
//  AdvertConfig.swift
//  XBADBaseDemo
//
//  Created by 全尼古拉斯 on 2020/3/26.
//  Copyright © 2020 全尼古拉斯. All rights reserved.
//

import UIKit

typealias expireParam = ([String: Any])
typealias loadParam = (source: String, placementId: String, success: Bool, error: Int?, msg: String?, duration: Double, groupLoadInfo: [[String: Any]])
typealias rawardedvideoParam = (action: String, param: [String: Any]?)
typealias interstitialAdParam = (action: String, param: [String: Any]?)

class AdvertConfig {
    static let shared = AdvertConfig()
    var config: SSPAdvertConfig?
    func configAdSdk(types: [ADType]) {
        for type in types {
            switch type {
            case .admob:
                break
            case .appnext:
                break
            case .baidu:
                break
            case .facebook:
                break
            case .mintegral:
                break
            case .appLovin:
                break
            default:
                break
            }
        }
    }
    
    var sspLoadCallback: ((loadParam) ->())?
    var sspExpireCallback: ((expireParam)->())?
    var rewardedvideoCallback: ((rawardedvideoParam) -> ())?
    var interstitialAdCallback: ((interstitialAdParam) -> ())?

//    func registerAd(nativeAd: [String], rvAd: [String], interstitialAd: [String]) {
//        XbAdManager.shared.registerAd(by: nativeAd)
//        XBRewardVideoManager.shared.registerAd(by: rvAd)
//    }
    
    func startAd(sspLoadCallback: ((loadParam) ->())?,
                 sspExpireCallback: (([String: Any])->())?,
                 sspClickCallback: (() ->())?,
                 rewardedvideoCallback: ((rawardedvideoParam) -> ())?) {
        
        self.sspLoadCallback = sspLoadCallback
        self.sspExpireCallback = sspExpireCallback
        self.rewardedvideoCallback = rewardedvideoCallback
    }
}
