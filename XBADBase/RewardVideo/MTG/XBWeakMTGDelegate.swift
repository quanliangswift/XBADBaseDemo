//
//  XBWeakMTGDelegate.swift
//  TopNews_SV
//
//  Created by 全尼古拉斯 on 2019/9/3.
//  Copyright © 2019 xb. All rights reserved.
//

import UIKit


class XBWeakMTGRewardAdLoadDelegate: NSObject, MTGRewardAdLoadDelegate {
   
    func onVideoAdLoadSuccess(_ unitId: String?) {
        mtgRewardAdLoadDelegate?.onVideoAdLoadSuccess?(unitId)
    }
    func onVideoAdLoadFailed(_ unitId: String?, error: Error) {
        mtgRewardAdLoadDelegate?.onVideoAdLoadFailed?(unitId, error: error)
    }
    weak var mtgRewardAdLoadDelegate: MTGRewardAdLoadDelegate?
    init(mtgRewardAdLoadDelegate: MTGRewardAdLoadDelegate) {
        super.init()
        self.mtgRewardAdLoadDelegate = mtgRewardAdLoadDelegate
    }
}

class XBWeakMTGRewardAdShowDelegate: NSObject, MTGRewardAdShowDelegate {
    func onVideoAdShowFailed(_ unitId: String?, withError error: Error) {
        mtgRewardAdShowDelegate?.onVideoAdShowFailed?(unitId, withError: error)
    }
    func onVideoAdShowSuccess(_ unitId: String?) {
        mtgRewardAdShowDelegate?.onVideoAdShowSuccess?(unitId)
    }
    
    func onVideoAdDismissed(_ unitId: String?, withConverted converted: Bool, withRewardInfo rewardInfo: MTGRewardAdInfo?) {
        mtgRewardAdShowDelegate?.onVideoAdDismissed?(unitId, withConverted: converted, withRewardInfo: rewardInfo)
    }
    func onVideoAdClicked(_ unitId: String?) {
        mtgRewardAdShowDelegate?.onVideoAdClicked?(unitId)
    }
    weak var mtgRewardAdShowDelegate: MTGRewardAdShowDelegate?
    init(mtgRewardAdShowDelegate: MTGRewardAdShowDelegate) {
        super.init()
        self.mtgRewardAdShowDelegate = mtgRewardAdShowDelegate
    }
}
