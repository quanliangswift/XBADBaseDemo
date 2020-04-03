//
//  XBRewardVideoManager.swift
//  TopNews_SV
//
//  Created by 全尼古拉斯 on 2019/9/20.
//  Copyright © 2019 xb. All rights reserved.
//

import UIKit


class RewardVideoModel: NSObject {
    var rvAd: Any?
    var placement: String = ""
    var price: Double = 0
    var source: String = ""
    var groupLoadInfo: [[String: Any]] = []
    var cacheTime: TimeInterval?
    override init() {
        super.init()
    }
}
enum SupportRewardedVideo: String, CaseIterable {
    case admob
    case facebook
    case mintegral
    case mediation // 聚合type
}

enum XbRVAction: String {
    case imp
    case load
    case click
    case close
    case playDone
}

protocol RVAdDelegate: class {
    var actionCallback: ((XbRVAction, String?) -> ())? { get set }
    func onCacheRVAd(placement: String, frequencyControl: FrequencyControl?, price: Double, complete: ((String, RewardVideoModel?, cacheResult, Int?)->())?)
    func showRV(rv: Any, placement: String, callback: ((Bool) -> ())?, actionCallback: ((XbRVAction, String?) -> ())?)
    func checkTimeout(rvAd: Any, placement: String?) -> Bool
    
    // 非聚合方式使用RV
    func setupRVAd(placement: String, actionCallback: ((XbRVAction, String?) -> ())?)
}

protocol RegisterRVAdDelegate: class {
    func registerFB(key: String)
    func registerAdmob(key: String)
    func registerMTG(key: String)
}
extension RegisterRVAdDelegate {
    func registerFB(key: String) {}
    func registerAdmob(key: String) {}
    func registerMTG(key: String) {}
}

class XBRewardVideoManager: NSObject, RegisterRVAdDelegate {
    static let shared = XBRewardVideoManager()
    deinit {
        let className = NSStringFromClass(self.classForCoder)
        print("\n\n---------deinit:\(className)---------\n\n")
    }

    var xbAdError: XbAdError = XbAdError.init()
    
    var id: String?
    var currentModel: RewardVideoModel?
    var startTime : Double = 0
    var isCaching: Bool = false
    var isFirstStart: CacheForType = .none
    
    var rvAdDelegates: [String: RVAdDelegate] = [:]
    func registerAd(by sources: [String]) {
        for source in sources {
            switch source {
            case "facebook":
                registerFB(key: source)
                break
            case "admob":
                registerAdmob(key: source)
            case "mintegral":
                registerMTG(key: source)
            default:
            break
            }
        }
    }

    enum CacheForType {
        case none
        case first
        case second
    }
    // 旧的聚合逻辑
    func getRewardVideoModel(id: String?, modelCallBack: @escaping ((RewardVideoModel?) -> ())) {
        print("XBRewardVideoManager----开始获取聚合RV")
        self.id = id
        // 本地没有缓存
        if currentModel == nil {
            print("XBRewardVideoManager----本地没有已缓存的RV")
            guard let _ = XbSDKIntegrationManager.shared.xbAdIntegration.rewardedVideoAds.first?.sdkGroup else {
                modelCallBack(nil)
                return
            }
            // 如果已经开始了缓存，则一秒之后，在尝试回调，不用请求
            if isCaching {
                print("XBRewardVideoManager----已经开始缓存，一秒钟之后尝试获取")
                _ = DelayTimer.delay(1, task: {
                    self.getRewardVideoModel(id: id, modelCallBack: modelCallBack)
                })
                return
            }
            
            // 如果当前的请求状态是空，则开始首次请求
            if isFirstStart == .none {
                print("XBRewardVideoManager----本地没有缓存，开始请求")
                isFirstStart = .first
            } else if isFirstStart == .first {
                print("XBRewardVideoManager----本地没有缓存，但是已经开始请求了，一秒钟之后重试")
                // 如果当前的请求状态为首次请求，但是又开始了新一轮的请求， 则将请求状态修改为二次请求，并在一秒之后，尝试回调，不发起请求
                isFirstStart = .second
                _ = DelayTimer.delay(1, task: {
                    self.getRewardVideoModel(id: id, modelCallBack: modelCallBack)
                })
                return
            } else {
                print("XBRewardVideoManager----本地没有缓存，但是已经开始请求了，一秒钟之后重试")
                // 如果当前状态为二次请求，则直接在一秒之后发起回调尝试，不用请求
                _ = DelayTimer.delay(1, task: {
                    self.getRewardVideoModel(id: id, modelCallBack: modelCallBack)
                })
                return
            }
            cacheRewardVideo(index: 0, callBack: { (model, _)  in
                // 如果当前请求状态为首次请求，则直接回调，消耗请求到的资源，并将请求状态重置
                if self.isFirstStart == .first {
                    print("XBRewardVideoManager----请求完成，是首次请求，直接回调")
                    modelCallBack(model)
                    self.isFirstStart = .none
                } else {
                    print("XBRewardVideoManager----请求完成，已经有下次请求了，所以保存在本地，供延时操作获取")
                    // 否则，将请求到的资源保存到本地
                    self.currentModel = model
                }
            })
        } else {
            // 本地已有资源
            // 回调消耗资源，重置请求状态，清空本地资源
            print("XBRewardVideoManager----本地已有缓存RV")
            modelCallBack(currentModel)
            isFirstStart = .none
        }
    }
    // 新的聚合逻辑
    func getRewardVideoModel2(source: String?, placement: String?) -> RewardVideoModel? {
        print("XBRewardVideoManager----开始获取聚合RV")
        // 本地没有缓存
        if currentModel == nil {
            print("XBRewardVideoManager----本地没有已缓存的RV")
            return nil
        } else {
            // 有source和placement， 说明已经从后台拿到要使用的广告
            if source != nil && placement != nil {
                if source == currentModel!.source && placement == currentModel!.placement {
                    // 本地已有资源
                    // 消耗资源，重置请求状态，清空本地资源
                    print("XBRewardVideoManager----本地已有缓存RV")
                    return currentModel
                } else {
                    return nil
                }
            } else {
                // 有source和placement， 说明是获取sdk_cache参数
                return currentModel
            }
        }
    }
    func getRewardedVideoSDKCacheParam(num: Int, complete: @escaping ((String) -> ())){
        if let current = getRewardVideoModel2(source: nil, placement: nil) {
            var sdkCache: [String: Any] = [:]
            sdkCache["xb_placement"] = "reward_video"
            var group: [[String: Any]] = []
            var item: [String: Any] = [:]
            item["source"] = current.source
            item["placement"] = current.placement
            item["price"] = current.price
            group.append(item)
            sdkCache["sdk_group"] = group
            complete(sdkCache.toJSONString() ?? "")
        } else {
            if Date().timeIntervalSince1970 - self.startTime > 300 || !isCaching {
                print("XBRewardVideoManager----开始缓存")
                isCaching = true
                let totalStartTime = Date().timeIntervalSince1970
                cacheRewardVideo(index: 0, groupLoadInfo: [], callBack: {[weak self] (model, groupLoadInfo) in
                    self?.currentModel = model
                    self?.currentModel?.cacheTime = Date().timeIntervalSince1970
                    self?.isCaching = false
                    let useTime = Date().timeIntervalSince1970 - totalStartTime
//                    self?.logSSPAdvertLoad(source: "sharp", placementId: "reward_video", success: model != nil, error: nil, msg: nil, duration: useTime, groupLoadInfo: groupLoadInfo)
                    AdvertConfig.shared.sspLoadCallback?((source: "sharp", placementId: "reward_video", success: model != nil, error: nil, msg: nil, duration: useTime, groupLoadInfo: groupLoadInfo))
                    
                    if model == nil {
                        complete("")
                    } else {
                        self?.getRewardedVideoSDKCacheParam(num: num, complete: complete)
                    }
                })
            } else {
                if num <= 15 {
                    DelayTimer.delay(1) {
                        self.getRewardedVideoSDKCacheParam(num: num + 1, complete: complete)
                    }
                } else {
                    complete("")
                }
            }
        }
    }
    
    /// 检查广告配置，是否有改动而删除旧的缓存广告
    /// 插屏广告
    /// - Parameter integrations:
    func checkGroupConfig(forRewardedVideo integrations: [XbSDKIntegration]) {
        
        tryCacheAllAd()
    }
    private func getXbSDKIntegration() -> (XbSDKIntegration?, Int) {
        let integration: XbSDKIntegration? = XbSDKIntegrationManager.shared.xbAdIntegration.rewardedVideoAds.first
        let slots: Int = XbSDKIntegrationManager.shared.xbAdIntegration.rewardedVideoAds.first?.slots ?? 0

        return (integration, slots)
    }
    
    func removeOldXbAdCache() {
        currentModel = nil
    }
    func tryCacheAllAd() {
        startCache()
    }
    
    func checkTimeout() {
        //  检查过期
        if currentModel == nil {
            return
        }
        var isTimeout: Bool = true
        if let delegate = rvAdDelegates[currentModel?.source ?? ""], let rvAd = currentModel?.rvAd {
            isTimeout = delegate.checkTimeout(rvAd : rvAd, placement: currentModel?.placement ?? "")
        }
        if isTimeout {
            // 检查到过期，上报
            let ad: [String: Any] = ["source": "sharp",
                                    "id": "",
                                    "placement_id": "reward_video",
                                    "info": currentModel?.groupLoadInfo.last?["ad"] as? [String : Any]]
//            self.logSSPAdvertExpire(ad: ad)
            AdvertConfig.shared.sspExpireCallback?(ad)
            removeOldXbAdCache()
        }
    }
    // 当缓存资源释放之后，开始重新请求资源
    func startCache() {
        checkTimeout()
        
        if currentModel != nil {
            return
        }
        if isCaching {
            return
        }
        isCaching = true
        print("XBRewardVideoManager----开始缓存")
        let totalStartTime = Date().timeIntervalSince1970
        cacheRewardVideo(index: 0, groupLoadInfo: [], callBack: { (model, groupLoadInfo) in
            self.currentModel = model
            self.currentModel?.cacheTime = Date().timeIntervalSince1970
            self.isCaching = false
            let useTime = Date().timeIntervalSince1970 - totalStartTime
//            self.logSSPAdvertLoad(source: "sharp", placementId: "reward_video", success: model != nil, error: nil, msg: nil, duration: useTime, groupLoadInfo: groupLoadInfo)
            AdvertConfig.shared.sspLoadCallback?((source: "sharp", placementId: "reward_video", success: model != nil, error: nil, msg: nil, duration: useTime, groupLoadInfo: groupLoadInfo))
        })
    }
    
    private func cacheRewardVideo(index: Int, groupLoadInfo: [[String: Any]] = [], callBack: @escaping ((RewardVideoModel?, [[String: Any]]) -> ())) {
        let integration = getXbSDKIntegration().0
        guard let rewardedVideos = integration?.sdkGroup, rewardedVideos.count > 0 else {
            callBack(nil, groupLoadInfo)
            return
        }
        let frequencyControl = integration?.frequencyControl
        let realIndex = index % rewardedVideos.count
        print("XBRewardVideoManager----请求第\(realIndex) 项")
        // 请求了一圈
        if index >= rewardedVideos.count {
            print("XBRewardVideoManager----请求了一圈都没有请求到")
            callBack(nil, groupLoadInfo)
            return
        }
        let rewardedVideo = rewardedVideos[realIndex]
        guard let type = SupportRewardedVideo.init(rawValue: rewardedVideo.source ?? "") else {
            print("XBRewardVideoManager----不支持该类型的RV")
            self.cacheRewardVideo(index: index + 1, groupLoadInfo: groupLoadInfo, callBack: callBack)
            return
        }
        var tempGroupLoadInfo: [[String: Any]] = groupLoadInfo
        
        // 判断placement是否频繁触发load
        if Date().timeIntervalSince1970 - rewardedVideo.lastLoadAdTime < rewardedVideo.reqIntervalTime {
            var loadInfoItem: [String: Any] = [:]
            loadInfoItem["ad"] = ["id": "",
                                  "source": rewardedVideo.source ?? "",
                                  "placement_id": rewardedVideo.placement ?? ""]
            loadInfoItem["result"] = ["success": false,
                                      "error": XbAdError.NATIVE_AD_REQ_INTERVAL_TIME_ERROR_CODE,
                                      "placement_id": rewardedVideo.placement ?? "",
                                      "msg": XbAdError.NATIVE_AD_REQ_INTERVAL_TIME]
            print("----XBAD---XB_AD_xbplacement保存---过滤---:", "reward_video", rewardedVideo.toJSON(), loadInfoItem)
            tempGroupLoadInfo.append(loadInfoItem)
            self.cacheRewardVideo(index: index + 1, groupLoadInfo: tempGroupLoadInfo, callBack: callBack)
            return
        }
       
        if let delegate = rvAdDelegates[type.rawValue ?? ""] {
            startTime = Date().timeIntervalSince1970 * 1000
            
            cacheRVAd(delegate: delegate, source: type.rawValue ?? "", placement: rewardedVideo.placement ?? "", frequencyControl: frequencyControl, price: rewardedVideo.price) { (placement, model, cacheResult, triggerCode) in
                let nowTime = Date().timeIntervalSince1970 * 1000
                self.setLog(action: "loading", nowTime: nowTime, startTime: self.startTime, success: cacheResult.errorCode == 0, reason: cacheResult.errorCode, msg: cacheResult.msg, source: type.rawValue, placement:  placement)
                

                tempGroupLoadInfo.append(self.loadInfo(source: type.rawValue, placement: placement, triggerCode: triggerCode, cacheResult: cacheResult))

                // 请求结束，记录时间
                // 不是限频导致的请求失败，记录时间
                if cacheResult.errorCode != XbAdError.NATIVE_AD_NO_MORE_TRY_ERROR_CODE {
                    self.recordLastLoadAdTime(xbPlacement: "reward_video", placement: placement)
                }

                if cacheResult.errorCode != 0 {
                    print("XBRewardVideoManager----\(type.rawValue ?? "") RV请求失败，尝试下一个")
                    self.xbAdError.setError(by: type.rawValue ?? "", placement: placement, errorCode: cacheResult.errorCode)
                    self.cacheRewardVideo(index: index + 1, groupLoadInfo: tempGroupLoadInfo, callBack: callBack)
                } else {
                    print("XBRewardVideoManager----\(type.rawValue ?? "") RV请求成功，回调")
                    model?.groupLoadInfo = tempGroupLoadInfo
                    callBack(model, tempGroupLoadInfo)
                }
            }

        } else {
            self.cacheRewardVideo(index: index + 1, groupLoadInfo: tempGroupLoadInfo, callBack: callBack)
        }
    }
    
    func loadInfo(source: String?, placement: String, triggerCode: Int?, cacheResult: cacheResult) -> [String: Any] {
        var loadInfoItem: [String: Any] = [:]
        loadInfoItem["ad"] = ["id": "",
                              "source": source,
                              "placement_id": placement,
                              "title": "" ,
                              "desc": ""]
        loadInfoItem["result"] = ["success": cacheResult.errorCode == 0,
                                  "error": cacheResult.errorCode,
                                  "placement_id": placement,
                                  "msg": cacheResult.msg,
                                  "duration": cacheResult.duration,
                                  "trigger_code": triggerCode]
        return loadInfoItem
    }
    
    // 记录placement上次load的时间，用以作为判断是否进入请求限频逻辑
    func recordLastLoadAdTime(xbPlacement: String, placement: String) {
        if xbPlacement == "" || placement == "" {
            return
        }
        for (index, rewardVideo) in XbSDKIntegrationManager.shared.xbAdIntegration.rewardedVideoAds.enumerated() {
            if (rewardVideo.xbPlacement ?? "") == xbPlacement {
                for (key, value) in (rewardVideo.sdkGroup ?? []).enumerated() {
                    if value.placement == placement {
                        XbSDKIntegrationManager.shared.xbAdIntegration.rewardedVideoAds[index].sdkGroup?[key].lastLoadAdTime = Date().timeIntervalSince1970
                    }
                }
            }
        }
    }
    
}
extension XBRewardVideoManager {
    func setLog(action : String, nowTime : Double? = 0, startTime : Double? = 0,success: Bool, reason: Int, msg: String, source: String, placement: String) {
        logRewardedVideoResult(id: id, from: "", source: source, placementName: placement, action: action, duration: nowTime! - startTime!,success: success, reason: reason, msg: msg)
    }
    
    func logRewardedVideoResult(id: String?, from : String, source : String, placementName : String, action : String, duration : Double?,success: Bool, reason: Int, msg: String) {
            var params : [String : Any] = ["from":from,
                                           "source":source,
                                           "placement_name":placementName,
                                           "action":action,
                                           "duration":duration ?? 0,
                                           "success":success,
                                           "reason":reason,
                                           "msg":msg]
            if id != nil {
                params["id"] = id!
            }
            AdvertConfig.shared.rewardedvideoCallback?((action: "rewardedvideo", param: params))
        }
  
}


extension XBRewardVideoManager {
    // 检查error code是否达到最大限度
    func checkErrorCode(frequencyItems: [FrequencyControlItem], errorDic: [Int: XbAdErrorItem]) -> (Bool, Int) {
        var tempErrorDic = errorDic
        // 是否可以继续请求广告
        var isContinue: Bool = true
        var errorCode: Int = 0
        for item in frequencyItems {
            if let error = tempErrorDic[item.code ?? 0] {
                if Date().timeIntervalSince1970 - error.time > item.wait {
                    tempErrorDic[item.code ?? 0] = nil
                } else {
                    isContinue = false
                    errorCode = item.code ?? 0
                    break
                }
            }
        }
        return (isContinue, errorCode)
    }
}
extension XBRewardVideoManager {
  
    // 请求缓存RV广告
    func cacheRVAd(delegate: RVAdDelegate, source: String, placement: String, frequencyControl: FrequencyControl?, price: Double, complete: ((String, RewardVideoModel?, cacheResult, Int?)->())?) {
        //            限频操作
        let startTime: Double = Date().timeIntervalSince1970
        if let frequencyItems = frequencyControl?.getControl(by: source), let errorItems = xbAdError.getError(by: source, placement: placement) {
            let result = checkErrorCode(frequencyItems: frequencyItems, errorDic: errorItems)
            if !result.0 {
                complete?(placement, nil, (XbAdError.NATIVE_AD_NO_MORE_TRY_ERROR_CODE, XbAdError.NATIVE_AD_MSG_NO_MORE_TRY, Date().timeIntervalSince1970 - startTime), result.1)
                
                return
            }
        }
        
        delegate.onCacheRVAd(placement: placement, frequencyControl: frequencyControl, price: price, complete: complete)
    }
}

extension XBRewardVideoManager {
    // 显示已缓存的RV
    func showCacheRV(model: RewardVideoModel, callback: ((Bool) -> ())?, actionCallback: ((XbRVAction, String?) -> ())?) {
        if let delegate = rvAdDelegates[model.source] {
            delegate.showRV(rv: model.rvAd, placement: model.source, callback: callback, actionCallback: actionCallback)
        } else {
            callback?(false)
        }
    }
}
// 非聚合的激励视频的显示
extension XBRewardVideoManager {
    func setupRV(source: String, placement: String, actionCallback: ((XbRVAction, String?) -> ())?) {
        if let delegate = rvAdDelegates[source] {
            delegate.setupRVAd(placement: placement, actionCallback: actionCallback)
        }
    }
}
