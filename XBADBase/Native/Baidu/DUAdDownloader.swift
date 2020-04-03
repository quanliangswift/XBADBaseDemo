//
//  DUAdDownloader.swift
//  TopNews
//
//  Created by xb on 2019/4/12.
//  Copyright © 2019年 xb. All rights reserved.
//

import UIKit
import DUModuleSDK
class DUAdDownloader: NSObject, DUNativeAdsManagerDelegate, NativeAdDownloaderDelegate {
    
    deinit {
        let className = NSStringFromClass(self.classForCoder)
        print("\n\n---------deinit:\(className)---------\n\n")
    }
    var cacheCallBack: ((_ id: Int64, _ isTooFrequently:  Bool, _ lastFrequentlyTime:  Double, _ errorCode: Int, _ msg:  String, _ placementID:  String, _ nativeAd:  DUNativeAd?)->())?
    
    var id = Int64(arc4random())
    var placementId: String = ""
    var adsMgr: DUNativeAdsManager?
    func cacheAd(placementId: String) {
        self.placementId = placementId
        adsMgr = DUNativeAdsManager.init(placementID: placementId, cacheSize: 1)
        adsMgr?.delegate = self
        adsMgr?.loadAds()
    }
    func nativeAdsLoaded(_ nativeAds: [DUNativeAd]) {
        if nativeAds.count > 0 {
            cacheCallBack?(id, false, 0, 0, "", nativeAds[0].placementID, nativeAds[0])
        } else {
            cacheCallBack?(id, false, 0, 0, "", placementId, nil)
        }
    }

    func nativeAdsFailedToLoadWithError(_ error: Error) {
        print("BAIDU Native ad failed to load with error: \(error)")
        var isTooFrequently = false
        var lastFrequentlyTime = 0.0
        if error.localizedDescription.contains("too frequently") {
            isTooFrequently = true
            lastFrequentlyTime = Date().timeIntervalSince1970
        }
        print((error as NSError).code)
        cacheCallBack?(id, isTooFrequently, lastFrequentlyTime, (error as NSError).code,error.localizedDescription, placementId, nil)
    }
}
