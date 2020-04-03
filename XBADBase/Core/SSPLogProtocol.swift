//
//  SSPLogProtocol.swift
//  TopNews
//  SSP广告的统计项
//  Created by xb on 2019/3/1.
//  Copyright © 2019年 xb. All rights reserved.
//

import UIKit
import Alamofire
//protocol StatisticsLogProtocol: class {
//    func logAd(label: String, parameters: [String: Any])
//}
//extension StatisticsLogProtocol {
//    func logAd(label: String, parameters: [String: Any]) {}
//}
// MARK: - SSP广告的统计项
//protocol SSPLogProtocol: class, LogParamsProtocol, SSPAdvertFillLogProtocol, StatisticsLogProtocol {
////    var news: News! {get set}
////    var trackerCallBack: ((Advert)->())? {get set}
//
//    /// - 点击上报
//    func onClickAdvert(advert: Advert, title: String?, desc: String?)
//
//
//    ///    广告资源加载
//    func logSSPAssetLoad(advert: Advert, success: Bool, url: String, usedtime: Double)
//}
//
//extension SSPLogProtocol {
//
//    //    MARK: - 统计项
//    ///    广告展示
//    func logSSPAdvertImp(advert: Advert, title: String?, desc: String?, isNative: Bool = true) {
//        let duration = (Date().timeIntervalSince1970 - advert.getStartImp()) * 1000
//        if isNative {
//            if duration < 50 {
//                return
//            }
//        }
//        let statisticsLogStr = "ssp_advert_imp2"
//        var params: [String : Any] = [:]
//        if advert.type == "sdk" && !(advert.usedDefaultAd ?? false) {
//            params["ad"] = getAdParams(advert: advert, title: title, desc: desc)
//        }
//
//        params["order"] = getOrderParams(advert: advert)
//
//        var resultParams: [String : Any] = [:]
//        resultParams["success"] = true
//        resultParams["duration"] = duration
//        params["result"] = resultParams
//        logAd(label: statisticsLogStr, parameters: params)
//    }
//
//    //    MARK: - 统计项
//    ///    激励视频或者插屏播放完成
//    func logSSPAdvertClose(advert: Advert, title: String?, desc: String?) {
//
//        let statisticsLogStr = "ssp_advert_close2"
//        var params: [String : Any] = [:]
//        if advert.type == "sdk" && !(advert.usedDefaultAd ?? false) {
//            params["ad"] = getAdParams(advert: advert, title: title, desc: desc)
//        }
//
//        params["order"] = getOrderParams(advert: advert)
//
//        var resultParams: [String : Any] = [:]
//        resultParams["success"] = true
//        params["result"] = resultParams
//        logAd(label: statisticsLogStr, parameters: params)
//    }
//
//
//    ///    广告点击
//    private func logSSPAdvertClick(advert: Advert, title: String?, desc: String?) {
//        let statisticsLogStr = "ssp_advert_click2"
//        var params: [String : Any] = [:]
//        if advert.type == "sdk" && !(advert.usedDefaultAd ?? false) {
//            params["ad"] = getAdParams(advert: advert, title: title, desc: desc)
//        }
//        params["order"] = getOrderParams(advert: advert)
//        var resultParams: [String : Any] = [:]
//        resultParams["success"] = true
//        params["result"] = resultParams
//        logAd(label: statisticsLogStr, parameters: params)
//    }
//    ///    广告资源加载
//    func logSSPAssetLoad(advert: Advert, success: Bool, url: String, usedtime: Double) {
//        let statisticsLogStr = "ssp_asset_load"
//        var params: [String : Any] = [:]
//        params["order"] = getOrderParams(advert: advert)
//        var resultParams: [String : Any] = [:]
//        resultParams["success"] = success
//        resultParams["url"] = url
////        resultParams["network"] = Utils.getNetworkType()
//        resultParams["used_ms"] = usedtime * 1000
//        params["result"] = resultParams
//        logAd(label: statisticsLogStr, parameters: params)
//    }
//
//    // MARK: - 点击上报
//    func onClickAdvert(advert: Advert, title: String?, desc: String?) {
//        print("clicktrackers: ---")
////        if news.itemType != NewsType.ITEM_TYPE_SSP_ADVERT.rawValue {
////            return
////        }
//        logSSPAdvertClick(advert: advert, title: title, desc: desc)
//
//        SSPTrackerManager.shared.logTracker(urls: advert.clicktrackers ?? [])
//        advert.clicktrackers?.removeAll()
////        trackerCallBack?(news)
//    }
//
//    //    MARK: - 曝光追踪
//    //正常的曝光追踪
//    func normalImpTracker(advert: Advert, impRate: CGFloat = -1, impTime: Double = -1) {
//
//        if let imptrackers = advert.imptrackers {
//            for (index, value) in imptrackers.enumerated() {
//                print("normalImpTracker: ---", advert.impid, impTime, impRate)
//                if (impRate == -1 && impTime == -1) || (value.impMinTime < impTime && value.impMinRate < impRate){
//                    SSPTrackerManager.shared.logTracker(urls: advert.imptrackers?[index].urls ?? [])
//                    advert.imptrackers?[index].urls?.removeAll()
//                }
//            }
//        }
//        advert.imptrackers = (advert.imptrackers ?? []).filter({ (tracker) -> Bool in
//            return (tracker.urls?.count ?? 0) > 0
//        })
////        trackerCallBack?(news)
//    }
//}
//
//// MARK: - 统计数据拼接
//protocol LogParamsProtocol: class {
//    //    MARK: - SDK广告信息
//    func getAdParams(advert: Advert, title: String?, desc: String?) -> [String: Any]
//    //    MARK: - 广告 订单 信息
//    func getOrderParams(advert: Advert) -> [String: Any]
//    //    MARK: - 统计 结果 信息
//    func getresultParams(success: Bool, error: Int?, msg: String?, duration: Int) -> [String: Any]
//}
//
//extension LogParamsProtocol {
//    //    MARK: - SDK广告信息
//    func getAdParams(advert: Advert, contentId: String, title: String?, desc: String?) -> [String: Any] {
//        var adParams: [String : Any] = [:]
//        adParams["id"] = contentId
//        adParams["source"] = advert.alliance?.source ?? ""
//        adParams["title"] = title
//        adParams["desc"] = desc
//        adParams["placement_id"] = advert.alliance?.placement ?? ""
////        adParams["group_load_info"] = news.advert?.groupLoadInfo ?? ""
//        adParams["info"] = advert.groupLoadInfo.last?["ad"]
//        return adParams
//    }
//    //    MARK: - 广告 订单 信息
//    func getOrderParams(advert: Advert) -> [String: Any] {
//        var orderParams: [String : Any] = [:]
//        orderParams["impid"] = advert.impid ?? ""
//        orderParams["styleid"] = advert.styleid ?? ""
//        orderParams["type"] = advert.type ?? ""
//        orderParams["order_id"] = advert.orderId ?? ""
//        orderParams["crid"] = advert.crid ?? ""
//        orderParams["sid"] = advert.sid ?? ""
//        return orderParams
//    }
//    //    MARK: - 统计 结果 信息
//    func getresultParams(success: Bool, error: Int?, msg: String?, duration: Int) -> [String: Any] {
//        var resultParams: [String : Any] = [:]
//        resultParams["success"] = success
//        resultParams["error"] = error
//        resultParams["msg"] = msg
//        resultParams["duration"] = duration
//        return resultParams
//    }
//}
//// MARK: - 广告失效过期的统计项
//protocol SSPAdvertExpireLogProtocol: class, StatisticsLogProtocol {
//    //    MARK: - 统计项
//    ///    广告过期, 只在SDK广告中有
//    func logSSPAdvertExpire(ad: [String: Any]?)
//}
//extension SSPAdvertExpireLogProtocol {
//    func logSSPAdvertExpire(ad: [String: Any]?) {
//        let statisticsLogStr = "ssp_advert_expire2"
//        var params: [String : Any] = [:]
//        //        if news.advert?.type == "sdk" && !(news.advert?.usedDefaultAd ?? false) {
//        //            params["ad"] = getAdParams(news: news, title: title, desc: desc)
//        //        }
//
//        //        params["order"] = getOrderParams(news: news)
//        params["ad"] = ad
//        var resultParams: [String : Any] = [:]
//        resultParams["success"] = true
//        params["result"] = resultParams
//        logAd(label: statisticsLogStr, parameters: params)
//        
//    }
//}
//
//// MARK: - 广告加载的统计项
//protocol SSPAdvertLoadLogProtocol: class, StatisticsLogProtocol {
//    //    MARK: - 统计项
//    ///    广告加载, 只在SDK广告中有
//    func logSSPAdvertLoad(source: String, placementId: String, success: Bool, error: Int?, msg: String?, duration: Double, groupLoadInfo: [[String: Any]])
//}
//extension SSPAdvertLoadLogProtocol {
//    func logSSPAdvertLoad(source: String, placementId: String, success: Bool, error: Int?, msg: String?, duration: Double, groupLoadInfo: [[String: Any]]) {
//        let statisticsLogStr = "ssp_advert_load"
//        var params: [String : Any] = [:]
//        var adParams: [String : Any] = [:]
//        adParams["source"] = source
//        adParams["placement_id"] = placementId
//        adParams["group_load_info"] = groupLoadInfo
//
//        params["ad"] = adParams
//        
//        var resultParams: [String : Any] = [:]
//        resultParams["success"] = success
//        resultParams["error"] = error
//        resultParams["msg"] = msg
//        resultParams["duration"] = duration
//        params["result"] = resultParams
//        
//        logAd(label: statisticsLogStr, parameters: params)
//    }
//}
//
//
//// MARK: - 广告填充的统计项
//protocol SSPAdvertFillLogProtocol: class, LogParamsProtocol, StatisticsLogProtocol {
//    //    MARK: - 统计项
//    ///    广告填充
//    func logSSPAdvertFill(advert: Advert, title: String?, desc: String?, success: Bool, error: Int?, msg: String?)
//}
//extension SSPAdvertFillLogProtocol {
//    //    MARK: - 统计项
//    ///    广告填充
//    func logSSPAdvertFill(advert: Advert, title: String?, desc: String?, success: Bool, error: Int?, msg: String?) {
//        let statisticsLogStr = "ssp_advert_fill2"
//        var params: [String : Any] = [:]
//
//        if advert.type == "sdk" && !(advert.usedDefaultAd ?? false) {
//            params["ad"] = getAdParams(advert: advert, title: title, desc: desc)
//        }
//        params["order"] = getOrderParams(advert: advert)
//
//        var resultParams: [String : Any] = [:]
//        resultParams["success"] = success
//        resultParams["error"] = error
//        resultParams["msg"] = msg
//        params["result"] = resultParams
//        logAd(label: statisticsLogStr, parameters: params)
//    }
//}

////上报跟踪的链接上报
//class SSPTrackerManager: NSObject {
//
//    static let shared = SSPTrackerManager.init()
//    private var failUrlsDict: [String: TimeInterval] = [:]
//    private var failUrls: [String] = []
//    let invalidTime: Double = 3 * 60 * 60
//
//    func logTracker(urls: [String]) {
//        if urls.count == 0 { return }
//        let group = DispatchGroup()
//        for urlString in urls {
//            print("normalTracker: ---log", urlString)
//            group.enter()
//            Alamofire.request(urlString).response{ (result) in
//
//                if result.response?.statusCode == 200 {
//                    // 上报成功
//                    self.failUrlsDict.removeValue(forKey: urlString)
//                    self.retryLogFailTracker()
//                } else {
//                    if self.failUrlsDict[urlString] == nil {
//                        self.failUrlsDict[urlString] = Date().timeIntervalSince1970
//                    }
//                }
//                group.leave()
//            }
//        }
//        group.notify(queue: .main) {
//            for (url, failTime) in self.failUrlsDict {
//                if Date().timeIntervalSince1970 - failTime < self.invalidTime {
//                    self.failUrls.append(url)
//                }
//            }
//        }
//    }
//
//    func retryLogFailTracker() {
//        logTracker(urls: failUrls)
//        failUrls.removeAll()
//    }
//}
