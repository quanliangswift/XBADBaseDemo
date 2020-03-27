//
//  AdEnum.swift
//  TopNews_SV
//
//  Created by xb on 2019/8/6.
//  Copyright © 2019 xb. All rights reserved.
//

import UIKit

// itemType 17的时候，广告advert为SDK的时候，如果AdSourceType == sdk，直接从旧的缓存池中取
// AdSourceType == sharp的时候，从ssp缓存池中取，有比价
enum AdSourceType: String {
    case sdk = "sdk"
    case sharp = "sharp"
}

// 现在集成的SDK广告类型
enum ADType: String {
    case admob = "admob"
    case facebook = "facebook"
    case baidu = "baidu"
    case appnext = "appnext"
    case mintegral = "mintegral"
}
// 现在配置有ssp的XB广告位
enum XBPlacementType: String {
    case feeds = "feeds"
    case relative = "relative"
    case article_bottom = "article_bottom"
    case reward_popup = "reward_popup"
    case public_item = "public"
    case none = ""
}
