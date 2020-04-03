//
//  XbGoogleAdProtocol.swift
//  TopNews
//
//  Created by xb on 2019/4/8.
//  Copyright © 2019年 xb. All rights reserved.
//

import UIKit
import GoogleMobileAds

class XbGoogleAdManager: NativeAdDelegate {
    static let shared = XbGoogleAdManager()
    var googleAdDownloaders: [Int64 : GoogleAdDownloader] = [:]
    func fetchNativeAd(item: SDKGroupItem, duplicate: Int, complete: ((Any?, String, String, cacheResult) -> ())?) {
        let startTime: Double = Date().timeIntervalSince1970
        let placementId = item.placement ?? ""
        let cache = GoogleAdDownloader()
        cache.cacheCallBack = { (id, errorCode, msg, placementID, nativeAd) in
            let title = nativeAd?.headline ?? ""
            let desc = nativeAd?.body ?? ""
            self.googleAdDownloaders[id] = nil
            complete?(nativeAd, title, desc, (errorCode, msg, Date().timeIntervalSince1970 - startTime))
        }
        cache.cacheAd(placementId: placementId)
        self.googleAdDownloaders[cache.id] = cache
    }
}
