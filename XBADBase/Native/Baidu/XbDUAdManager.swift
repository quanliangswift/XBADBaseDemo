//
//  XbDUAdProtocol.swift
//  TopNews
//
//  Created by xb on 2019/4/12.
//  Copyright © 2019年 xb. All rights reserved.
//

import UIKit
import DUModuleSDK

class XbDUAdManager: NativeAdDelegate {
    static let shared = XbDUAdManager()
    var duAdDownloaders: [Int64 : DUAdDownloader] = [:]
    func fetchNativeAd(item: SDKGroupItem, duplicate: Int, complete: ((Any?, String, String, cacheResult) -> ())?) {
        let startTime: Double = Date().timeIntervalSince1970
        let placementId = item.placement ?? ""
        let cache = DUAdDownloader()
        self.duAdDownloaders[cache.id] = cache
        cache.cacheCallBack = {[weak self] (id, _, _, errorCode, msg, placementId, nativeAd) in
            let title = nativeAd?.title ?? ""
            let desc = nativeAd?.shortDesc ?? ""
            self?.duAdDownloaders[id] = nil
            complete?(nativeAd, title, desc, (errorCode, msg, Date().timeIntervalSince1970 - startTime))
        }
        cache.cacheAd(placementId: placementId)
    }
}
