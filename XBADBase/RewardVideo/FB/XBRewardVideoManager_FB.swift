//
//  XBRewardVideoManager_FB.swift
//  XBADBaseDemo
//
//  Created by 全尼古拉斯 on 2020/4/2.
//  Copyright © 2020 全尼古拉斯. All rights reserved.
//

import Foundation
extension XBRewardVideoManager {
    func registerFB(key: String) {
        rvAdDelegates[key] = XbFbRVManager.shared
    }
}



