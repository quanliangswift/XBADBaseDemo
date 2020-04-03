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
    case appLovin = "appLovin"
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

struct SSPAdvertStyle {
//    信息流 详情页 1张小图
    static let STYLEID_FEED_DETAIL_1 = "1"
//    信息流 详情页 3张小图
    static let STYLEID_FEED_DETAIL_2 = "2"
//    信息流 详情页 1张大图
    static let STYLEID_FEED_DETAIL_3 = "3"
//    信息流 详情页 mp4 gif
    static let STYLEID_FEED_DETAIL_4 = "4"
//    信息流 详情页 大图视频
    static let STYLEID_FEED_DETAIL_5 = "5"

//    开屏 图片
    static let STYLEID_SPLASH_1 = "19"
//    开屏 gif
    static let STYLEID_SPLASH_2 = "20"
//    开屏 视频
    static let STYLEID_SPLASH_3 = "21"
//    相关推荐 1张小图
    static let STYLEID_CONTENT_1 = "23"
//    搜索顶部banner 1张小图
    static let STYLEID_SEARCH_BANNER_1 = "27"
//    详情页中部banner 1张大图
    static let STYLEID_ARTICLE_BANNER = "28"
    
    static let STYLEID_VAST = "29"
    // 激励视频
    static let STYLEID_REWARDED_VIDEO = "8"
    // 插屏广告
    static let STYLEID_INTERSTITAL_AD = "7"
    static let STYLEID_VAST_INSTREAM = "30"
}
