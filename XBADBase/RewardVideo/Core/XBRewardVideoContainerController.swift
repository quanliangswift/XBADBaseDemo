//
//  XBRewardVideoContainerController.swift
//  TopNews_SV
//
//  Created by xb on 2019/8/26.
//  Copyright © 2019 xb. All rights reserved.
//

//import UIKit
//import FBAudienceNetwork
//import GoogleMobileAds
//import ObjectMapper
//import SwiftyJSON
//
//class XBRewardVideoModel: Mappable {
//    var data: JSON?
//    var ret: Int?
//    required init?(map: Map) {
//    }
//    func mapping(map: Map) {
//        data <- map["data"]
//        ret <- map["ret"]
//    }
//}
//
//class XBRewardVideoContainerController: UIViewController {
////    var news: News! = News()
////    var trackerCallBack: ((News) -> ())?
////    var currentNews: News?
//    var currentAdvert: Advert?
//    // rewardedvideo
//    var id : String?
//    var onCompleteVideo : ((String?)->())?
//    var onJSCompleteVideo1 : ((String,Bool,Bool,Bool,Bool,Double)->())?
//    var rewardValue : Double?
//    var rewardName : String?
//
//    // rewardedVideo2
//    var from: String = "list"
//    var source: String = ""
//    var placement: String = ""
//    var callbackUrl: String = ""
//    var callbackInfo: [String: Any] = [:]
//    var disableRequestReward: Bool = false
//    var disableShowRewarded: Bool = false
//    var onJSCompleteVideo2: ((Bool,Bool,Bool,Bool,JSON?)->())?
//
//    var startTime : Double = 0
//    var hasCompleteVideo : Bool = false
//
//    var isRewardVideo2: Bool = true
//    var useMediation: Bool = false // 是否使用聚合的方式
//    var fbRewardedVideoAd: FBRewardedVideoAd?
//
//    var weakMTGRewardAdLoadDelegate: XBWeakMTGRewardAdLoadDelegate?
//    var weakMTGRewardAdShowDelegate: XBWeakMTGRewardAdShowDelegate?
//
//
////    var sspCloseCallback: ((closeParam)->())?
////    var sspFillCallback: ((fillParam)->())?
////    var sspImpCallback: ((impParam)->())?
//    var rewardedvideoCallback: ((rawardedvideoParam)->())?
//
//    deinit {
//        let className = NSStringFromClass(self.classForCoder)
//        print("\n\n---------deinit:\(className)---------\n\n")
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.view.backgroundColor = UIColor.clear
//        setupRewardVideo()
//    }
//
//    func setupRewardVideo() {
////        self.showNoticeWait()
//        startTime = Date().timeIntervalSince1970 * 1000
//        let type = SupportRewardedVideo.init(rawValue: source)
//
//        if type == SupportRewardedVideo.mediation || type == nil  {
//            startSetupMediation2()
//            return
//        }
//
//        if let _ = SupportRewardedVideo.init(rawValue: source) {
//            startSetup()
//        }
////        else if let rewardedVideo = ObjectCache.loadRemoteConfigs()?.rewardedVideos.first,
////            let source = rewardedVideo.source,
////            let placement = rewardedVideo.placement,
////            let _ = SupportRewardedVideo.init(rawValue: source) {
////            self.source = source
////            self.placement = placement
////            startSetup()
////        } else {
////            self.source = "admob"
////            self.placement = "ca-app-pub-3382180995277275/5386627275"
////            startSetup()
////        }
//    }
//
//    func fetchRewardOnComplete() {
//        if isRewardVideo2 {
//            fetchRewardOnComplete2()
//        } else {
//            fetchRewardOnComplete1()
//        }
//    }
//
//    func rewardVideoAdFail(msg: String) {
//        if isRewardVideo2 {
//            rewardVideoAdFail2(msg: msg)
//        } else {
//            rewardVideoAdFail1(msg: msg)
//        }
//        reCacheRV()
//    }
//
//    @objc func dismissVC() {
////        self.clearWaitNotice()
//        self.dismiss(animated: true, completion: nil)
//    }
//
//}
///// rewardvideo
//extension XBRewardVideoContainerController {
//    func fetchRewardOnComplete1() {
//        let nowTime = Date().timeIntervalSince1970 * 1000
//        setLog(action: "browse", nowTime: nowTime, startTime: startTime, success: true, reason: 0, msg: "")
//        // 消耗了激励视频的缓存资源，重新开始缓存
//        _ = DelayTimer.delay(1, task: {
//            XBRewardVideoManager.shared.startCache()
//        })
//        if hasCompleteVideo {
////            self.showNoticeWait()
//            LogicAPI.fetchRewardedVideoRd(id: id, from: from, source: source, placementName: placement, rewardValue: rewardValue, rewardName: rewardName, onSuccessed: { [weak self] (rd) in
////                self?.clearWaitNotice()
//                RewardedVideoRDView.showRewardedVideoRDView(value: rd.rewardValue ?? 0)
//                self?.onCompleteVideo?(self?.id)
//                self?.setLog(action: "reward", success: true, reason: 0, msg: "")
//                self?.onJSCompleteVideo1?(self?.id ?? "",true,true,true,true,rd.rewardValue ?? 0)
//                self?.dismiss(animated: false, completion: nil)
//                }, onFailed: {[weak self] (status, msg) in
////                    self?.clearWaitNotice()
////                    self?.showNoticeText(String(format: Utils.getLocalizedString("rewarded_video_reward_failed_format", comment: ""), status))
//                    self?.onJSCompleteVideo1?(self?.id ?? "",true,true,true,false,0)
//                    self?.setLog(action: "reward", success: false, reason: status, msg: msg)
//                    self?.dismiss(animated: false, completion: nil)
//                }, onError: {[weak self] in
////                    self?.clearWaitNotice()
////                    self?.showNoticeText(Utils.getLocalizedString("rewarded_video_reward_failed", comment: ""))
//                    self?.onJSCompleteVideo1?(self?.id ?? "",true,true,true,false,0)
//                    self?.setLog(action: "reward", success: false, reason: -1, msg: "")
//                    self?.dismiss(animated: false, completion: nil)
//            })
//        } else {
//            onJSCompleteVideo1?(id ?? "",true,true,false,false,0)
//            self.dismiss(animated: false, completion: nil)
//        }
//    }
//
//    func rewardVideoAdFail1(msg: String) {
////        Utils.AppTopViewController()?.showNoticeText(Utils.getLocalizedString("rewarded_video_no_content"))
//
//        let nowTime = Date().timeIntervalSince1970 * 1000
//        setLog(action: "loading", nowTime: nowTime, startTime: startTime, success: false, reason: 0, msg: msg)
//        startTime = nowTime
//        onJSCompleteVideo1?(id ?? "",false,false,false,false,0)
//        self.dismissVC()
//    }
//}
///// rewardvideo2
//extension XBRewardVideoContainerController {
//    func fetchRewardOnComplete2() {
//        let nowTime = Date().timeIntervalSince1970 * 1000
//        setLog(action: "browse", nowTime: nowTime, startTime: startTime, success: true, reason: 0, msg: "")
//        if self.currentAdvert != nil {
////            logSSPAdvertClose(news: self.currentNews!, title: nil, desc: nil)
//            AdvertConfig.shared.sspCloseCallback?((advert: self.currentAdvert!, title: nil, desc: nil))
//        }
//        // 消耗了激励视频的缓存资源，重新开始缓存
//        reCacheRV()
//        if !hasCompleteVideo {
////            Utils.AppTopViewController()?.showNoticeText(Utils.getLocalizedString("no_reward_for_not_complete"))
//            onJSCompleteVideo2?(true,true,false,false,nil)
//            self.dismissVC()
//            return
//        }
//        if hasCompleteVideo, !disableRequestReward {
////            self.showNoticeWait()
//            let params: [String: Any] = ["callback_info": callbackInfo]
//            JSONRequest<XBRewardVideoModel>().post(url: callbackUrl)
//                .paras(p: params)
//                .go(keys: [], onSuccessed: { [weak self] (result) in
//                    let resultJson = result.data
//                    if !(self?.disableShowRewarded ?? false), let xu = resultJson?["rewarded_xu"].double {
//                        _ = Utils.delay(1, task: {
//                            let controller = RewardAdvertController.init()
//                            controller.modalPresentationStyle = .overCurrentContext
//                            controller.modalTransitionStyle = .crossDissolve
//                            controller.rewardText = AppUtils.numtoVNNum(num: xu) + " XU"
//                            controller.style = RewardAdvertStyle.xu
//                            Utils.AppTopViewController()?.showDetailViewController(controller, sender: self)
//                        })
//                    }
//                    self?.setLog(action: "reward", success: true, reason: 0, msg: "")
//                    self?.onJSCompleteVideo2?(true,true,true,true,resultJson)
//                    NotificationCenter.default.post(name: NSNotification.Name.init("xb_rewardvideo_fetch_reward_success"), object: nil)
//                    // StatisticsEvent.logEvent(statisticsName: StatisticsName.SV_REWARD_DOUBLE_POP_VIEW_GET_DOUBLE_REWARD, trigDic: ["from": self?.from])
//                    self?.dismissVC()
//                    }, onFailed: {[weak self] (status, msg) in
////                        self?.showNoticeText(String(format: Utils.getLocalizedString("rewarded_video_reward_failed_format", comment: ""), status))
//                        self?.onJSCompleteVideo2?(true,true,true,false,nil)
//                        self?.setLog(action: "reward", success: false, reason: status, msg: msg)
//                        self?.dismissVC()
//                    }, onError: {[weak self] in
////                        self?.showNoticeText(Utils.getLocalizedString("rewarded_video_reward_failed", comment: ""))
//                        self?.onJSCompleteVideo2?(true,true,true,false,nil)
//                        self?.setLog(action: "reward", success: false, reason: -1, msg: "")
//                        self?.dismissVC()
//                })
//        } else {
//            onJSCompleteVideo2?(true,true,true,false,nil)
//            self.dismissVC()
//        }
//    }
//    func rewardVideoAdFail2(msg: String) {
////        Utils.AppTopViewController()?.showNoticeText(Utils.getLocalizedString("rewarded_video_no_content"))
//
//        let nowTime = Date().timeIntervalSince1970 * 1000
//        setLog(action: "loading", nowTime: nowTime, startTime: startTime, success: false, reason: 0, msg: msg)
//        startTime = nowTime
//        onJSCompleteVideo2?(false,false,false,false,nil)
//        self.dismissVC()
//    }
//}
//
///// 非聚合
//extension XBRewardVideoContainerController {
//    func startSetup() {
//        useMediation = false
//        guard let type = SupportRewardedVideo.init(rawValue: source) else {
////            Utils.AppTopViewController()?
////                .showNoticeText(Utils.getLocalizedString("rewarded_video_no_content"))
//            if isRewardVideo2 {
//                self.onJSCompleteVideo2?(false,false,false,false,nil)
//            } else {
//                onJSCompleteVideo1?(id ?? "",false,false,false,false,0)
//            }
//
//            self.dismissVC()
//            return
//        }
//        XBRewardVideoManager.shared.setupRV(source: type.rawValue, placement: placement) {[weak self] (action, msg) in
//            switch action {
//            case .click:
//                SSPLogManager.shared.onClickAdvert(advert: self?.currentAdvert, title: nil, desc: nil)
//            break
//            case .close:
//                DelayTimer.delay(1, task: {
//                    self?.fetchRewardOnComplete()
//                })
//            break
//            case .imp:
//                self?.logImp()
//            break
//            case .load:
//                let nowTime = Date().timeIntervalSince1970 * 1000
//                self?.setLog(action: "loading", nowTime: nowTime, startTime: self?.startTime, success: true, reason: 0, msg: "")
//                self?.startTime = nowTime
//
//                if msg == nil {
//
//                } else {
//                    self?.rewardVideoAdFail(msg: msg!)
//                }
//            break
//            case .playDone:
//                self?.hasCompleteVideo = true
//            break
//
//            }
//        }
//    }
//}
///// 聚合方式
//extension XBRewardVideoContainerController {
//    // 采用聚合的方式
//    func startSetupMediation() {
//        useMediation = true
//        XBRewardVideoManager.shared.getRewardVideoModel(id: id, modelCallBack: {[weak self] (model) in
//            if model != nil {
//
//                XBRewardVideoManager.shared.showCacheRV(model: model!, callback: { (success) in
//                    if !success {
//                        self?.rewardVideoMediationFail()
//                    }
//                }) {[weak self] (action, msg) in
//                           switch action {
//                           case .click:
//                            SSPLogManager.shared.onClickAdvert(advert: self?.currentAdvert, title: nil, desc: nil)
//                           break
//                           case .close:
//                               DelayTimer.delay(1, task: {
//                                   self?.fetchRewardOnComplete()
//                               })
//                           break
//                           case .imp:
//                               self?.logImp()
//                           break
//                           case .load:
//                               let nowTime = Date().timeIntervalSince1970 * 1000
//                               self?.setLog(action: "loading", nowTime: nowTime, startTime: self?.startTime, success: true, reason: 0, msg: "")
//                               self?.startTime = nowTime
//
//                               if msg == nil {
//
//                               } else {
//                                   self?.rewardVideoAdFail(msg: msg!)
//                               }
//                           break
//                           case .playDone:
//                               self?.hasCompleteVideo = true
//                           break
//
//                           }
//                       }
//            } else {
//                //                Utils.AppTopViewController()?.showNoticeText(Utils.getLocalizedString("rewarded_video_no_content"))
//                self?.rewardVideoMediationFail()
//            }
//        })
//    }
//
//
//    func rewardVideoMediationFail(needRecache: Bool = true) {
//        if isRewardVideo2 {
//            onJSCompleteVideo2?(false,false,false,false,nil)
//        } else {
//            onJSCompleteVideo1?(id ?? "",false,false,false,false,0)
//        }
//        if needRecache {
//           reCacheRV()
//        }
//        self.dismissVC()
//    }
//    // 重新缓存RV
//    func reCacheRV() {
//        _ = DelayTimer.delay(1, task: {
//            if self.useMediation {
//                XBRewardVideoManager.shared.currentModel = nil
//            }
//            XBRewardVideoManager.shared.startCache()
//            self.currentAdvert = nil
//        })
//    }
//}
//
//extension XBRewardVideoContainerController {
//    func logImp(success: Bool = true) {
//        if currentAdvert == nil {return}
//        AdvertConfig.shared.sspFillCallback?((advert: currentAdvert!, title: nil, desc: nil, success: success, error: nil, msg: nil))
//        // 曝光上报和回调
//        AdvertConfig.shared.sspImpCallback?((advert: currentAdvert!, title: nil, desc: nil, isNative: false))
////        self.normalImpTracker()
//        SSPLogManager.shared.normalImpTracker(advert: self.currentAdvert!)
//    }
//
//    // 请求后台聚合判断
//    func startSetupMediation2() {
//        // 本地没有缓存，线性去拉缓存， 15秒拉不到，点击屏幕可退出
//        let dismissResult = DelayTimer.delay(15, task: {
//            self.view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(self.dismissVC)))
//        })
//        useMediation = true
//        XBRewardVideoManager.shared.getRewardedVideoSDKCacheParam(num: 0) { [weak self] (sdkCache) in
//            // 拉到缓存，取消延迟任务
//            DelayTimer.cancel(dismissResult)
//
//            LogicAPI.fetchRV(source: self?.from, sdkCache: sdkCache, onSuccessed: { [weak self] (advert) in
//                let news = News.init()
//                news.itemType = NewsType.ITEM_TYPE_SSP_ADVERT.rawValue
//                news.contentId = Int64(arc4random())
//                self?.news = news
//                news.startImp()
//
//                self?.dealwith(advert: advert, callback: {[weak self] success in
//                    guard let self = self else {
//                        return
//                    }
//                    news.advert = advert
//                    self.currentNews = news
//                    if !success {
//                        self.logImp(success: false)
//                    }
//                })
//                }, onFailed: { [weak self] (_, _) in
//                    self?.rewardVideoMediationFail(needRecache: false)
//                }, onError: { [weak self] in
//                    self?.rewardVideoMediationFail(needRecache: false)
//            })
//        }
//    }
//
//    func dealwith(advert: Advert, callback: ((Bool) -> ())?){
//        if advert.type == "sdk" {
//            var source: String?
//            var placement: String?
//            // 小步聚合
//            if advert.alliance?.source == "sharp" {
//                source = advert.alliance?.sdkCache?.sdkGroup?.first?.source
//                placement = advert.alliance?.sdkCache?.sdkGroup?.first?.placement
//            } else {
//                source = advert.alliance?.source
//                placement = advert.alliance?.placement
//            }
//            if let current = XBRewardVideoManager.shared.getRewardVideoModel2(source: source, placement: placement) {
//                advert.groupLoadInfo = current.groupLoadInfo
//                // 拿到符合后台要求的聚合缓存RV，开始展示
//
//                XBRewardVideoManager.shared.showCacheRV(model: current, callback: { (success) in
//                    if !success {
//                        self.rewardVideoMediationFail()
//                    }
//                    callback?(success)
//                }) {[weak self] (action, msg) in
//                           switch action {
//                           case .click:
//                               SSPLogManager.shared.onClickAdvert(advert: self?.currentAdvert, title: nil, desc: nil)
//                           break
//                           case .close:
//                               DelayTimer.delay(1, task: {
//                                   self?.fetchRewardOnComplete()
//                               })
//                           break
//                           case .imp:
//                               self?.logImp()
//                           break
//                           case .load:
//                               let nowTime = Date().timeIntervalSince1970 * 1000
//                               self?.setLog(action: "loading", nowTime: nowTime, startTime: self?.startTime, success: true, reason: 0, msg: "")
//                               self?.startTime = nowTime
//
//                               if msg == nil {
//
//                               } else {
//                                self?.rewardVideoAdFail(msg: msg!)
//                               }
//                           break
//                           case .playDone:
//                               self?.hasCompleteVideo = true
//                           break
//
//                           }
//                       }
//            } else {
//                // 聚合的RV不符合后台下发的要求， 开始请求指定source,placment 的RV
////                self.source = source ?? ""
////                self.placement = placement ?? ""
////                startSetup()
//
//                callback?(false)
//                self.rewardVideoMediationFail(needRecache: false)
//            }
//        } else if advert.type == "ssp" && advert.admnative != nil && advert.styleid == SSPAdvertStyle.STYLEID_REWARDED_VIDEO {
//            showXBRV(advert: advert)
//            logImp()
//            callback?(true)
//        } else {
//            callback?(false)
//            self.rewardVideoMediationFail()
//        }
//    }
//    // 显示自由激励视频
//    func showXBRV(advert: Advert) {
////        let vc = XBRewardedVideoController.init()
////        vc.advert = advert
////        vc.delegate = self
////        vc.modalPresentationStyle = .custom
////        Utils.AppTopViewController()?.showDetailViewController(vc, sender: self)
//    }
//}
//extension XBRewardVideoContainerController {
//    func setLog(action : String, nowTime : Double? = 0, startTime : Double? = 0,success: Bool, reason: Int, msg: String) {
//        logRewardedVideoResult(id: id, from: from, source: source, placementName: placement, action: action, duration: nowTime! - startTime!,success: success, reason: reason, msg: msg)
//
//    }
//
//    func logRewardedVideoResult(id: String?, from : String, source : String, placementName : String, action : String, duration : Double?,success: Bool, reason: Int, msg: String) {
//            var params : [String : Any] = ["from":from,
//                                           "source":source,
//                                           "placement_name":placementName,
//                                           "action":action,
//                                           "duration":duration ?? 0,
//                                           "success":success,
//                                           "reason":reason,
//                                           "msg":msg]
//            if id != nil {
//                params["id"] = id!
//            }
//    //        StatisticsLogManager.shared.log(label: "rewardedvideo", parameters: params)
//        AdvertConfig.shared.rewardedvideoCallback?((action: "rewardedvideo", param: params))
//        }
//}
//
////extension XBRewardVideoContainerController : LinkHandlerProtocol {
////    static func setupViewController() -> LinkHandlerProtocol {
////        let controller = XBRewardVideoContainerController()
////        controller.modalPresentationStyle = .custom
////        return controller
////    }
////
////    func mapping(url: URL) {
////        let rewarded = RewardedVideo.init()
////        let params = LinkHandler.parseParams(url: url)
////        if let id = params?["id"], id.isEmpty == false {
////            rewarded.id = id
////        }
////
////        if let placement = params?["placement"], placement.isEmpty == false {
////            self.placement = placement
////        }
////        if let source = params?["source"], source.isEmpty == false {
////            self.source = source
////        }
////        if let from = params?["from"], from.isEmpty == false {
////            self.from = from
////        }
////        if let callback_url = params?["callback_url"], callback_url.isEmpty == false {
////            self.callbackUrl = callback_url
////        }
////        if let callback_info = params?["callback_info"] {
////            if let data = Data.init(base64Encoded: callback_info, options: Data.Base64DecodingOptions.ignoreUnknownCharacters) {
////                self.callbackInfo = (String.init(data: data, encoding: String.Encoding.utf8) ?? "").toDictionary() ?? [:]
////            }
////        }
////    }
////
////    func checkPermissions() -> Bool {
////        return true
////    }
////
////    func getViewController() -> UIViewController {
////        return self
////    }
////
////    var openType: LinkOpenType {
////        return .present
////    }
////}
