//
//  XbFbAdProtocol.swift
//  TopNews
//
//  Created by xb on 2019/4/8.
//  Copyright © 2019年 xb. All rights reserved.
//

import UIKit
import FBAudienceNetwork

class XbFbAdManager: NativeAdDelegate {
    static let shared = XbFbAdManager()
    var fbAdDownloaders: [Int64 : FBAdDownloader] = [:]
    func fetchNativeAd(item: SDKGroupItem, duplicate: Int, complete: ((Any?, String, String, cacheResult) -> ())?) {
        let startTime: Double = Date().timeIntervalSince1970
        let placementId = item.placement ?? ""
        let cache = FBAdDownloader()
        cache.cacheCallBack = { (id, _, _, errorCode, msg, placementId, nativeAd) in
            let title = nativeAd?.headline ?? ""
            let desc = nativeAd?.bodyText ?? ""
            self.fbAdDownloaders[id] = nil
            complete?(nativeAd, title, desc, (errorCode, msg, Date().timeIntervalSince1970 - startTime))
        }
        cache.cacheAd(placementId: placementId)
        self.fbAdDownloaders[cache.id] = cache
    }
}
