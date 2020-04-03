//
//  DUBannerAdView.h
//  DUModuleSDK
//
//  Created by jinwenhai on 2018/3/27.
//  Copyright © 2018年 baidu. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "DUAdDefines.h"
#import "DUAdConstants.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DUBannerAdViewDelegate;

/**
 A customized UIView to represent a banner ad.
 */
DU_CLASS_EXPORT DU_SUBCLASSING_RESTRICTED
@interface DUBannerAdView : UIView

/**
 This is a method to initialize an DUBannerAdView matching the given placement id.
 
 - Parameter placementID: The id of the ad placement. You can create your placement id from DAP developers page.
 - Parameter adSize: The size of the ad; for example, kDUBannerAdSize320x50.
 - Parameter viewController: The view controller that will be used to present the ad and the app store view.
 */
- (instancetype)initWithPlacementID:(NSString *)placementID
                             adSize:(DUBannerAdSize)adSize
                 rootViewController:(nullable UIViewController *)viewController NS_DESIGNATED_INITIALIZER;

/**
 Begins loading the DUBannerAdView content.
 
 
 You can implement `adViewDidLoad:` and `adView:didFailWithError:` methods
 of `DUBannerAdViewDelegate` if you would like to be notified as loading succeeds or fails.
 */
- (void)loadAd;

/**
 Typed access to the id of the ad placement.
 */
@property (nonatomic, copy, readonly) NSString *placementID;
/**
 Typed access to the app's root view controller.
 */
@property (nonatomic, weak, readonly, nullable) UIViewController *rootViewController;
/**
 the delegate
 */
@property (nonatomic, weak, nullable) id<DUBannerAdViewDelegate> delegate;

@end

/**
 The methods declared by the DUBannerAdViewDelegate protocol allow the adopting delegate to respond
 to messages from the DUBannerAdView class and thus respond to operations such as whether the ad has
 been loaded.
 */
@protocol DUBannerAdViewDelegate <NSObject>

@optional

/**
 Sent when an ad has been successfully loaded.
 
 - Parameter adView: An DUBannerAdView object sending the message.
 */
- (void)adViewDidLoad:(DUBannerAdView *)adView;

/**
 Sent after an DUBannerAdView fails to load the ad.
 
 - Parameter adView: An DUBannerAdView object sending the message.
 - Parameter error: An error object containing details of the error.
 */
- (void)adView:(DUBannerAdView *)adView didFailWithError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END

