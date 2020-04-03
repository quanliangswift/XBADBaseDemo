//
//  XbMTGAdProtocol.swift
//  TopNews_SV
//
//  Created by xb on 2019/8/8.
//  Copyright © 2019 xb. All rights reserved.
//

import UIKit

class XbMTGAdManager: NativeAdDelegate {
    static let shared = XbMTGAdManager()
    var mtgAdDownloaders: [Int64 : MTGAdDownloader] = [:]
    func fetchNativeAd(item: SDKGroupItem, duplicate: Int, complete: ((Any?, String, String, cacheResult) -> ())?) {
        let startTime: Double = Date().timeIntervalSince1970
        let placementId = item.placement ?? ""
        let cache = MTGAdDownloader()
        self.mtgAdDownloaders[cache.id] = cache
        cache.cacheCallBack = {[weak self] (id, _, _, errorCode, msg, placementId, adModel) in
            let title = adModel?.nativeAd?.appName ?? ""
            let desc = adModel?.nativeAd?.appDesc ?? ""
            self?.mtgAdDownloaders[id] = nil
            complete?(adModel, title, desc, (errorCode, msg, Date().timeIntervalSince1970 - startTime))
        }
        cache.cacheAd(placementId: placementId)
    }
}
