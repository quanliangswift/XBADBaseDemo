//
//  XbFbAdProtocol.swift
//  TopNews
//
//  Created by xb on 2019/4/8.
//  Copyright © 2019年 xb. All rights reserved.
//

import UIKit
import FBAudienceNetwork

protocol XbFbAdProtocol: class {
    var nativeAdDownloaders: [Int64 : NativeAdDownloaderDelegate] { get set }
    
    func fetchFbAd(item: SDKGroupItem, duplicate: Int, complete: ((FBNativeAd?, String, String, cacheResult) -> ())?)
}

extension XbFbAdProtocol {
    func fetchFbAd(item: SDKGroupItem, duplicate: Int, complete: ((FBNativeAd?, String, String, cacheResult) -> ())?) {
        let startTime: Double = Date().timeIntervalSince1970
        let placementId = item.placement ?? ""
        let cache = FBAdDownloader()
        cache.cacheCallBack = { (id, _, _, errorCode, msg, placementId, nativeAd) in
            let title = nativeAd?.headline ?? ""
            let desc = nativeAd?.bodyText ?? ""
            self.nativeAdDownloaders[id] = nil
            complete?(nativeAd, title, desc, (errorCode, msg, Date().timeIntervalSince1970 - startTime))
        }
        cache.cacheAd(placementId: placementId)
        self.nativeAdDownloaders[cache.id] = cache
    }
}
