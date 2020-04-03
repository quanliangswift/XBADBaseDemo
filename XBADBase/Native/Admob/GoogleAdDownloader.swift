//
//  GoogleAdDownloader.swift
//  TopNews
//
//  Created by xb on 2019/3/30.
//  Copyright © 2019年 xb. All rights reserved.
//

import UIKit
import GoogleMobileAds

class GoogleAdDownloader: NSObject, GADAdLoaderDelegate, GADUnifiedNativeAdLoaderDelegate, NativeAdDownloaderDelegate {
    deinit {
        let className = NSStringFromClass(self.classForCoder)
        print("\n\n---------deinit:\(className)---------\n\n")
    }
    var cacheCallBack: ((_ id: Int64,_ errorCode: Int, _ errorMsg:  String, _ placementID:  String, _ nativeAd:  GADUnifiedNativeAd?)->())?
    var id = Int64(arc4random())
    var adLoader: GADAdLoader = GADAdLoader.init()
   
    func cacheAd(placementId: String) {
        adLoader = GADAdLoader(adUnitID: placementId, rootViewController: nil, adTypes: [ .unifiedNative ], options: nil)
        adLoader.delegate = self
        let request = GADRequest()
//        request.testDevices = ["07cea19b7baa75484ee5d1f744b28869"]
        adLoader.load(request)
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
        cacheCallBack?(id, 0, "", adLoader.adUnitID, nativeAd)
    }
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        print("google Ad 请求失败了")
        cacheCallBack?(id, error.code, error.localizedDescription, adLoader.adUnitID, nil)
    }
}
