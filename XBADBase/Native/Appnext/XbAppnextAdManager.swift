//
//  XbAppnextAdProtocol.swift
//  TopNews_SV
//
//  Created by xb on 2019/8/2.
//  Copyright © 2019 xb. All rights reserved.
//

import UIKit
class XbAppnextAdManager: NativeAdDelegate {
    static let shared = XbAppnextAdManager()
    var appnextAdDownloaders: [Int64 : AppnextAdDownloader] = [:]
    func fetchNativeAd(item: SDKGroupItem, duplicate: Int, complete: ((Any?, String, String, cacheResult) -> ())?) {
        let startTime: Double = Date().timeIntervalSince1970
        let placementId = item.placement ?? ""
        let cache = AppnextAdDownloader()
        cache.cacheCallBack = { (id, errorCode, msg, placementID, AdModel) in
            let title = AdModel?.adData?.title ?? ""
            let desc = AdModel?.adData?.desc ?? ""
            self.appnextAdDownloaders[id] = nil
            complete?(AdModel, title, desc, (errorCode, msg, Date().timeIntervalSince1970 - startTime))
        }
        cache.cacheAd(placementId: placementId)
        self.appnextAdDownloaders[cache.id] = cache
    }
}
