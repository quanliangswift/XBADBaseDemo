//
//  FBAdDownloader.swift
//  TopNews
//
//  Created by xb on 2019/3/30.
//  Copyright © 2019年 xb. All rights reserved.
//

import UIKit
import FBAudienceNetwork


class FBAdDownloader: NSObject, FBNativeAdDelegate, NativeAdDownloaderDelegate {
    deinit {
        let className = NSStringFromClass(self.classForCoder)
        print("\n\n---------deinit:\(className)---------\n\n")
    }
    var cacheCallBack: ((_ id: Int64, _ isTooFrequently:  Bool, _ lastFrequentlyTime:  Double, _ errorCode: Int, _ msg:  String, _ placementID:  String, _ nativeAd:  FBNativeAd?)->())?
    var id = Int64(arc4random())
 
    
    func cacheAd(placementId: String) {
        let nativeAd : FBNativeAd = FBNativeAd.init(placementID: placementId)
        nativeAd.delegate = self
        nativeAd.loadAd(withMediaCachePolicy: .all)
    }
    func nativeAdDidLoad(_ nativeAd: FBNativeAd) {
        cacheCallBack?(id, false, 0, 0, "", nativeAd.placementID, nativeAd)
    }
    func nativeAd(_ nativeAd: FBNativeAd, didFailWithError error: Error) {
        print("Native ad failed to load with error: \(error)")
        var isTooFrequently = false
        var lastFrequentlyTime = 0.0
        if error.localizedDescription.contains("too frequently") {
            isTooFrequently = true
            lastFrequentlyTime = Date().timeIntervalSince1970
        }
        print((error as NSError).code)
        cacheCallBack?(id, isTooFrequently, lastFrequentlyTime, (error as NSError).code,error.localizedDescription, nativeAd.placementID, nil)
    }
    
}
