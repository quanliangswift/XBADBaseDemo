//
//  AppnextAdDownLoader.swift
//  TopNews_SV
//
//  Created by xb on 2019/7/3.
//  Copyright © 2019 xb. All rights reserved.
//

import UIKit

class AppnextAdDownloader: NSObject, AppnextNativeAdsRequestDelegate, NativeAdDownloaderDelegate {
    deinit {
        
        let className = NSStringFromClass(self.classForCoder)
        print("\n\n---------deinit:\(className)---------\n\n")
    }
    var cacheCallBack: ((_ id: Int64, _ errorCode: Int, _ msg:  String, _ placementID:  String, _ nativeAd:  AppnextAdModel?)->())?
    var id = Int64(arc4random())
    var adModel: AppnextAdModel = AppnextAdModel.init()
    
    func cacheAd(placementId: String) {
        if let vc = Utils.AppTopViewController() {
            let api = AppnextNativeAdsSDKApi.init(placementID: placementId, with: vc)
            let request: AppnextNativeAdsRequest = AppnextNativeAdsRequest.init()
            request.count = 1
            request.clickInApp = true
            request.creativeType = .managed
            api?.loadAds(request, with: self)
            adModel.api = api
        } else {
            cacheCallBack?(id, 1, "no vc", placementId, nil)
        }
    }
    
    func onAdsLoaded(_ ads: [AppnextAdData]!, for request: AppnextNativeAdsRequest!) {
        adModel.adData = ads.first
        cacheCallBack?(id, 0, "", adModel.api?.placementID ?? "", adModel)
    }
    func onError(_ error: String!, for request: AppnextNativeAdsRequest!) {
        cacheCallBack?(id, 1, error, adModel.api?.placementID ?? "", nil)
    }
}
