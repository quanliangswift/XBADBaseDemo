//
//  XbInterstitialAdManager_FB.swift
//  XBADBaseDemo
//
//  Created by 全尼古拉斯 on 2020/4/2.
//  Copyright © 2020 全尼古拉斯. All rights reserved.
//

import Foundation
extension XbInterstitialAdManager {
    func registerFB(key: String) {
        interstitialAdDelegates[key] = XbFbInterstitialManager.shared
    }
}
