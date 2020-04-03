//
//  XbInterstitialAdManager.swift
//  TopNews
//
//  Created by xb on 2019/5/28.
//  Copyright © 2019 xb. All rights reserved.
//

import UIKit
import ObjectMapper
import FBAudienceNetwork
import GoogleMobileAds
import AppLovinSDK
class InterstitialAdModel: NSObject {
//    var InterstitialAd: FBInterstitialAd?
//    var AdmobInterstitialAd: DFPInterstitial?
//    var MTGIVAdManager: MTGInterstitialVideoAdManager?
    var interstitialAd: Any?
//    var ALInterstitialAd: ALAd?
    var adId: String = ""
    var id: String = ""
    var from: String = ""
    var source: String = ""
    var placement: String = ""
    var price: Double = 0
    var duration: Double = 0
    var startShow: TimeInterval = 0
    var groupLoadInfo: [[String: Any]] = []
    var cacheTime: TimeInterval?
    override init() {
        super.init()
        adId = UUID.init().uuidString.lowercased()
    }
}
enum InterstitialAdType: String {
    case facebook
    case admob
    case mintegral
    case applovin
}

protocol InterstitialAdDelegate: class {
//    var actionCallback: ((XbRVAction, String?) -> ())? { get set }
    func onCacheInterstitialAd(placement: String, id: String, from: String, callback: @escaping ((_ errorCode: Int, _ msg:  String, _ placementID:  String, _ model:  InterstitialAdModel)->()))
    func showInterstitialAd(model: InterstitialAdModel, adId: String, adDic: [String: Any], callback: @escaping ((Int, String, String, [String: Any]) -> Void), closeCallback: (()->())?)
    
    
//    func checkTimeout(rvAd: Any, placement: String?) -> Bool
//
//    // 非聚合方式使用RV
//    func setupRVAd(placement: String, actionCallback: ((XbRVAction, String?) -> ())?)
}

protocol RegisterInterstitialAdDelegate: class {
    func registerFB(key: String)
    func registerAdmob(key: String)
    func registerMTG(key: String)
    func registerAL(key: String)
}
extension RegisterInterstitialAdDelegate {
    func registerFB(key: String) {}
    func registerAdmob(key: String) {}
    func registerMTG(key: String) {}
    func registerAL(key: String) {}
}

class XbInterstitialAdManager: NSObject, RegisterInterstitialAdDelegate {
    static let shared = XbInterstitialAdManager()
    deinit {
        let className = NSStringFromClass(self.classForCoder)
        print("\n\n---------deinit:\(className)---------\n\n")
    }
    
    var interstitialAdDelegates: [String: InterstitialAdDelegate] = [:]
    func registerAd(by sources: [String]) {
        for source in sources {
            switch source {
            case "facebook":
                registerFB(key: source)
            case "admob":
                registerAdmob(key: source)
            case "mintegral":
                registerMTG(key: source)
            case "appLovin":
                registerAL(key: source)
            default:
            break
            }
        }
    }
    
    var xbInterstitialAdDic: [String: InterstitialAdModel] = [:]

    var currentModel: InterstitialAdModel?
    
    
    //缓存插屏广告
    //callback(id, errorCode, msg, placementID, adId)
    func cacheAd(source: String, placement: String, id: String, from: String, callback: @escaping ((Int, String, InterstitialAdModel) -> Void)) {
        if let delegate = interstitialAdDelegates[source] {
            delegate.onCacheInterstitialAd(placement: placement, id: id, from: from) { (errorCode, msg, placementID, model) in
                if model.interstitialAd != nil {
                    self.xbInterstitialAdDic[model.adId] = model
                }
                callback(errorCode, msg, model)
            }
        } else {
            let model = InterstitialAdModel()
            model.source = source
            model.placement = placement
            model.id = id
            model.from = from
            callback(1001, "", model)
        }
//        if source == InterstitialAdType.facebook.rawValue {
//            let downLoader = FBInterstitialAdDownLoader()
//            downLoader.cacheCallBack = { (errorCode, msg, placementID, model) in
//                if model.InterstitialAd != nil {
//                    self.xbInterstitialAdDic[model.adId] = model
//                }
//                callback(errorCode, msg, model)
//                self.fbInterstitialDownLoader[id] = nil
//            }
//            downLoader.cacheFBAd(placementId: placement, id: id, from: from, price: 0)
//            fbInterstitialDownLoader[id] = downLoader
//        } else if source == InterstitialAdType.admob.rawValue {
//            let downLoader = GoogleInterstitialAdDownLoader()
//            downLoader.cacheCallBack = { (errorCode, msg, placementID, model) in
//                if model.AdmobInterstitialAd != nil {
//                    self.xbInterstitialAdDic[model.adId] = model
//                }
//                callback(errorCode, msg, model)
//                self.googleInterstitialDownLoader[id] = nil
//            }
//            downLoader.cacheGoogleAd(placementId: placement, id: id, from: from, price: 0)
//            googleInterstitialDownLoader[id] = downLoader
//        } else if source == InterstitialAdType.mintegral.rawValue {
//            let downLoader = MTGInterstitialAdDownLoader()
//            downLoader.cacheCallBack = { (errorCode, msg, placementID, model) in
//                if model.MTGIVAdManager != nil {
//                    self.xbInterstitialAdDic[model.adId] = model
//                }
//                callback(errorCode, msg, model)
//                self.mtgInterstitialDownLoader[id] = nil
//            }
//            downLoader.cacheMTGAd(placementId: placement, id: id, from: from, price: 0)
//            mtgInterstitialDownLoader[id] = downLoader
//        } else if source == InterstitialAdType.applovin.rawValue {
//            let downLoader = ALInterstitialAdDownLoader()
//            downLoader.cacheCallBack = { (errorCode, msg, placementID, model) in
//                if model.ALInterstitialAd != nil {
//                    self.xbInterstitialAdDic[model.adId] = model
//                }
//                callback(errorCode, msg, model)
//                self.alInterstitialDownLoader[id] = nil
//            }
//            downLoader.cacheALAd(placementId: placement, id: id, from: from, price: 0)
//            alInterstitialDownLoader[id] = downLoader
//        } else {
//            let model = InterstitialAdModel()
//            model.source = source
//            model.placement = placement
//            model.id = id
//            model.from = from
//            callback(1001, "", model)
//        }
    }
    func showInterstitialAD(adId: String, callback: @escaping ((Int, String, String, [String: Any]) -> Void)) {
        guard let model = xbInterstitialAdDic[adId] else {
            callback(1002, "", adId, [:])
            return
        }
        xbInterstitialAdDic[adId] = nil
        currentModel = model
        var adDic = [String: Any]()
        adDic["placement_name"] = currentModel?.placement ?? ""
        adDic["ad_id"] = currentModel?.adId ?? ""
        adDic["from"] = currentModel?.from ?? ""
        adDic["source"] = currentModel?.source ?? ""
        adDic["id"] = currentModel?.id ?? ""
        
        if let delegate = interstitialAdDelegates[currentModel?.source ?? ""], let ad = model.interstitialAd  {
            delegate.showInterstitialAd(model: currentModel!, adId: adId, adDic: adDic, callback: callback, closeCallback: {
                self.didCloseLog()
            })
        } else {
            callback(1002, "", adId, adDic)
        }
//        if model.source == InterstitialAdType.facebook.rawValue {
//            if let ad = model.InterstitialAd {
//
//                ad.delegate = self
//                if ad.isAdValid {
//                    ad.show(fromRootViewController: Utils.AppTopViewController())
//                    currentModel!.startShow = Date().timeIntervalSince1970
//                    callback(0, "", adId, adDic)
//                    return
//                }
//                callback(1003, "", adId, adDic)
//                return
//            }
//        } else if model.source == InterstitialAdType.admob.rawValue {
//            if let ad = model.AdmobInterstitialAd {
//
//                ad.delegate = self
//                if ad.isReady, let vc = Utils.AppTopViewController() {
//                    ad.present(fromRootViewController: vc)
//                    currentModel!.startShow = Date().timeIntervalSince1970
//                    callback(0, "", adId, adDic)
//                    return
//                }
//                callback(1003, "", adId, adDic)
//                return
//            }
//        } else if model.source == InterstitialAdType.mintegral.rawValue {
//            if let ad = model.MTGIVAdManager {
//                ad.delegate = self
//                if ad.isVideoReady(toPlay: ad.currentUnitId), let vc = Utils.AppTopViewController() {
//                    ad.show(from: vc)
//                    currentModel!.startShow = Date().timeIntervalSince1970
//                    callback(0, "", adId, adDic)
//                    return
//                }
//                callback(1003, "", adId, adDic)
//                return
//            }
//        } else if model.source == InterstitialAdType.applovin.rawValue {
//            if let ad = model.ALInterstitialAd {
//                ALInterstitialAd.shared().adDisplayDelegate = self
//                ALInterstitialAd.shared().adVideoPlaybackDelegate = self
//                ALInterstitialAd.shared().show(ad)
//                currentModel!.startShow = Date().timeIntervalSince1970
//                callback(0, "", adId, adDic)
//                return
//            }
//        }
//        callback(1002, "", adId, adDic)
    }
    
    func didCloseLog() {
        var ad = [String: Any]()
        ad["placement_name"] = currentModel?.placement ?? ""
        ad["ad_id"] = currentModel?.adId ?? ""
        ad["from"] = currentModel?.from ?? ""
        ad["source"] = currentModel?.source ?? ""
        ad["id"] = currentModel?.id ?? ""
        
        var result = [String: Any]()
        result["success"] = true
        result["error"] = 0
        result["msg"] = ""
        let nowTime = Date().timeIntervalSince1970
        result["duration"] = nowTime - (currentModel?.startShow ?? nowTime)
        
        var eventValue = [String: Any]()
        eventValue["ad"] = ad
        eventValue["result"] = result
        
//        StatisticsLogManager
//            .shared.log(label: "interstitial_show", parameters: eventValue)
        AdvertConfig.shared.interstitialAdCallback?((action: "interstitial_show", param: eventValue))
    }
}

//extension XbInterstitialAdManager: FBInterstitialAdDelegate {
//    func interstitialAdDidClose(_ interstitialAd: FBInterstitialAd) {
//        didCloseLog()
//    }
//}
//
//extension XbInterstitialAdManager: GADInterstitialDelegate {
//    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
//        didCloseLog()
//    }
//}
//extension XbInterstitialAdManager: MTGInterstitialVideoDelegate {
//    func onInterstitialVideoAdDismissed(withConverted converted: Bool, adManager: MTGInterstitialVideoAdManager) {
//        didCloseLog()
//    }
//}
//extension XbInterstitialAdManager: ALAdDisplayDelegate, ALAdVideoPlaybackDelegate {
//    func ad(_ ad: ALAd, wasDisplayedIn view: UIView) {
//    }
//    
//    func ad(_ ad: ALAd, wasHiddenIn view: UIView) {
//        didCloseLog()
//    }
//    
//    func ad(_ ad: ALAd, wasClickedIn view: UIView) {
//    }
//    
//    func videoPlaybackBegan(in ad: ALAd) {
//    }
//    
//    func videoPlaybackEnded(in ad: ALAd, atPlaybackPercent percentPlayed: NSNumber, fullyWatched wasFullyWatched: Bool) {
//    }
//}
