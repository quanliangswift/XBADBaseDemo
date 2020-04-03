//
//  DUNativeAdsManager.h
//  DUModuleSDK
//
//  Created by jinwenhai on 2018/5/18.
//  Copyright © 2018年 baidu. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DUAdDefines.h"
#import "DUNativeAd.h"

NS_ASSUME_NONNULL_BEGIN

/**
 @protocol DUNativeAdsManagerDelegate
 
 Messages from DUNativeAdsManager indicating success or failure loading ads.
 */
@protocol DUNativeAdsManagerDelegate <NSObject>

/**
 When the DUNativeAdsManager has finished loading a batch of ads this message will be sent. A batch of ads may be loaded in response to calling loadAds or due to an automatic refresh by the DUNativeAdsManager. At the point this message is fired all of the native ads will already be loaded and will not hence send their own nativeAdLoad: or nativeAd:didFailWithError: message.
 
 */
- (void)nativeAdsLoaded:(NSArray<DUNativeAd *> *)nativeAds;

/**
 When the DUNativeAdsManager has reached a failure while attempting to load a batch of ads this message will be sent to the application.
 - Parameter error: An NSError object with information about the failure.
 */
- (void)nativeAdsFailedToLoadWithError:(NSError *)error;

@end

/**
 This class provides a mechanism to fetch a set of ads and then use them within your application. The recommended usage is to call nextNativeAd: at the moment when you are about to render an ad. The native ads manager supports giving out as many ads as needed by cloning over the set of ads it got back from the server which can be useful for feed scenarios.
 */
DU_CLASS_EXPORT DU_SUBCLASSING_RESTRICTED
@interface DUNativeAdsManager : NSObject

/**
 The delegate
 */
@property (nonatomic, weak, nullable) id<DUNativeAdsManagerDelegate> delegate;

/*!
 @method
 
 @abstract
 This is a method to initialize a DUNativeAdsManager object matching the given placement id. This will use 10 as default cache size.
 
 @param placementID The id of the ad placement. You can create your placement id from Mobula developers page.
 */
- (instancetype)initWithPlacementID:(NSString*)placementID;

/**
 Initialize the native ads manager.
 
 - Parameter placementID: The id of the ad placement. You can create your placement id from DAP developers page.
 - Parameter aSize: The number of ads you would like the native ads manager to retrieve.
 */
- (instancetype)initWithPlacementID:(NSString *)placementID
                          cacheSize:(NSInteger)aSize NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)init NS_UNAVAILABLE;

/*!
 @method
 
 @abstract
 Begins loading the DUNativeAd content.
 
 @discussion You can implement `nativeAdsLoaded:` and `nativeAdsFailedToLoadWithError:` methods
 of `DUNativeAdsManagerDelegate` if you would like to be notified as loading succeeds or fails.
 */
- (void)loadAds;

/*!
 @method
 
 @abstract
 Begins loading the DUNativeAd content.
 
 @discussion pre-cache ad in advance for faster loading the ad.
 */
- (void)fillAds;

/*!
 @method
 
 @abstract Check if there is cached ad. Return true for having cache.
 
 @discussion .
 */
- (BOOL)isHasCached;

/*!
 @method
 
 @abstract Acquire advertising object data synchronously.
 
 @discussion .
 */
- (nullable NSArray<DUNativeAd *> *)getCacheAds;

@end

NS_ASSUME_NONNULL_END
