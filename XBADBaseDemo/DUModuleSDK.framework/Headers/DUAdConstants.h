//
//  DUAdConstants.h
//  DUModuleSDK
//
//  Created by baidu on 17/1/19.
//  Copyright © 2017年 baidu. All rights reserved.
//

#ifndef DUAdConstants_h
#define DUAdConstants_h

#define DUSV @"1.1.2"
#define DUSVN @"ios-1.1.2"

typedef NS_OPTIONS(NSInteger, DUAdChannelType) {
    DUAdChannelTypeUnknow = 1 << 0,
    DUAdChannelTypeDownload = 1 << 1,
    DUAdChannelTypeFacebook = 1 << 2,
    DUAdChannelTypeAdmob = 1 << 3,
    DUAdChannelTypeDownloadH = 1 << 4,
};

typedef NS_ENUM(NSInteger, DUAdLogLevel) {
    DUAdLogLevelNone,
    DUAdLogLevelDebug
};

typedef NS_ENUM(NSInteger, DUBannerAdSize) {
    kDUBannerAdSize320x50
};

#endif /* DUAdConstants_h */
