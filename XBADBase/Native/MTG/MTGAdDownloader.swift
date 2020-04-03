//
//  MTGAdDownloader.swift
//  TopNews_SV
//
//  Created by xb on 2019/8/7.
//  Copyright © 2019 xb. All rights reserved.
//

import UIKit

class MTGAdDownloader: NSObject, MTGNativeAdManagerDelegate, NativeAdDownloaderDelegate {
    
    deinit {
        let className = NSStringFromClass(self.classForCoder)
        print("\n\n---------deinit:\(className)---------\n\n")
    }
    var cacheCallBack: ((_ id: Int64, _ isTooFrequently:  Bool, _ lastFrequentlyTime:  Double, _ errorCode: Int, _ msg:  String, _ placementID:  String, _ adModel:  MTGAdModel?)->())?
    
    var id = Int64(arc4random())
    var placementId: String = ""
    var adsMgr: MTGNativeAdManager?
    func cacheAd(placementId: String) {
        self.placementId = placementId
        adsMgr = MTGNativeAdManager.init(unitID: placementId, fbPlacementId: nil, supportedTemplates: [MTGTemplate.init(type: MTGAdTemplateType.MTGAD_TEMPLATE_BIG_IMAGE, adsNum: 1)], autoCacheImage: false, adCategory: MTGAdCategory.MTGAD_CATEGORY_ALL, presenting: nil)
        adsMgr?.delegate = self
        adsMgr?.loadAds()
    }
    func nativeAdsLoaded(_ nativeAds: [Any]?, nativeManager: MTGNativeAdManager) {
        if nativeAds != nil, nativeAds!.count > 0 {
            let model = MTGAdModel()
            model.nativeAd = nativeAds![0] as? MTGCampaign
            model.manager = adsMgr
            cacheCallBack?(id, false, 0, 0, "", nativeManager.currentUnitId, model)
        } else {
            cacheCallBack?(id, false, 0, 0, "", placementId, nil)
        }
    }
    func nativeAdsFailedToLoadWithError(_ error: Error, nativeManager: MTGNativeAdManager) {
        print("MTG Native ad failed to load with error: \(error)")
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
