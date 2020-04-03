//
//  XBRewardVideoManager_admob.swift
//  XBADBaseDemo
//
//  Created by 全尼古拉斯 on 2020/4/2.
//  Copyright © 2020 全尼古拉斯. All rights reserved.
//

import Foundation
extension XBRewardVideoManager {
    func registerAdmob(key: String) {
        rvAdDelegates[key] = XbGoogleRVManager.shared
    }
}
