#
#  Be sure to run `pod spec lint XBADBaseDemo.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "XBADBaseDemo"
  spec.version      = "0.0.1.12"
  spec.summary      = "XBADBaseDemo for test"

  spec.description  = <<-DESC
  私有库测试
  自己用来测试的
  没什么用
                   DESC

  spec.homepage     = "https://github.com/quanliangswift/XBADBaseDemo"

  spec.license      = "MIT"



  spec.author             = { "全亮" => "quanliangani@gmail.com" }
 
  spec.platform     = :ios, "10.1"


  spec.source       = { :git => "https://github.com/quanliangswift/XBADBaseDemo.git", :tag => "#{spec.version}" }

  spec.swift_versions = ['5.0', '5.1']

  spec.frameworks = 'UIKit', 'Foundation'

  spec.dependency "SwiftyJSON"
  spec.dependency "ObjectMapper"
  spec.dependency "Alamofire"

# swift项目中有OC的第三方，在验证的时候加上--use-modular-headers
  spec.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'OTHER_LDFLAGS' => '-lObjC' }
  
  spec.subspec 'Core' do |ss|
  ss.source_files = 'XBADBase/Core/**/*.swift'
  # ss.source_files = 'XBADBase/Core/**/*.h'
  ss.dependency 'SDWebImage'
  
  end

  spec.subspec 'Native' do |ss|

    ss.subspec 'Core' do |coress|
      coress.source_files = 'XBADBase/Native/Core/*.swift'
      coress.dependency 'XBADBaseDemo/Core'
      coress.dependency 'SnapKit'
    end
    # ss.subspec 'FB' do |fbss|
    #   fbss.source_files = 'XBADBase/Native/FB/*.swift'
    #   fbss.dependency 'FBAudienceNetwork'
    #   fbss.dependency 'XBADBaseDemo/Native/Core'
    # end
    # ss.subspec 'Admob' do |admobss|
    #   admobss.source_files = 'XBADBase/Native/Admob/*.swift'
    #   admobss.dependency  'Google-Mobile-Ads-SDK', '7.48.0'
    #   admobss.dependency 'XBADBaseDemo/Native/Core'
    # end
    # ss.subspec 'Appnext' do |appnextss|
    #   appnextss.source_files = 'XBADBase/Native/Appnext/*.swift'
    #   appnextss.dependency 'XBADBaseDemo/Native/Core'
    #   # appnext 不支持pod，需要自己导入.a文件，并且在build setting -> header search path中加相关配置，例如 $(PROJECT_DIR)/XBADBaseDemo/Appnext/include
    # end
    # ss.subspec 'Baidu' do |baiduss|
    #   baiduss.source_files = 'XBADBase/Native/Baidu/*.swift'
    #   baiduss.dependency 'XBADBaseDemo/Native/Core'
      # baidu 不支持pod，需要自己导入.framework文件，
    # end
    ss.subspec 'MTG' do |mtgss|
      mtgss.source_files = 'XBADBase/Native/MTG/*.swift'
      mtgss.dependency 'MintegralAdSDK/NativeAd', '5.8.8.0'
      mtgss.dependency 'XBADBaseDemo/Native/Core'
      # mtgss.preserve_path = "${POD_ROOT}/XBADBaseDemo/Native/MTG/BridgingHeader.h"
      mtgss.pod_target_xcconfig = {'SWIFT_OBJC_BRIDGING_HEADER' => '${POD_ROOT}/XBADBaseDemo/Native/MTG/BridgingHeader.h'}
    end
  end

  # spec.subspec 'RewardVideo' do |ss|
  #   ss.subspec 'Core' do |coress|
  #     coress.source_files = 'XBADBase/RewardVideo/Core/*.swift'
  #     coress.dependency 'XBADBaseDemo/Core'
  #   end
  #   ss.subspec 'FB' do |fbss|
  #     fbss.source_files = 'XBADBase/RewardVideo/FB/*.swift'
  #     fbss.dependency 'FBAudienceNetwork'
  #     fbss.dependency 'XBADBaseDemo/RewardVideo/Core'
  #   end
  #   ss.subspec 'Admob' do |admobss|
  #     admobss.source_files = 'XBADBase/RewardVideo/Admob/*.swift'
  #     admobss.dependency  'Google-Mobile-Ads-SDK', '7.48.0'
  #     admobss.dependency 'XBADBaseDemo/RewardVideo/Core'
  #   end
  #   ss.subspec 'MTG' do |mtgss|
  #     mtgss.source_files = 'XBADBase/RewardVideo/MTG/*.swift'
  #     mtgss.dependency 'MintegralAdSDK/RewardVideoAd', '5.8.8.0'
  #     mtgss.dependency 'XBADBaseDemo/RewardVideo/Core'
  #   end
  # end

  # spec.subspec 'InterstitialAd' do |ss|
  #   ss.subspec 'Core' do |coress|
  #     coress.source_files = 'XBADBase/InterstitialAd/Core/*.swift'
  #     coress.dependency 'XBADBaseDemo/Core'
  #   end
  #   ss.subspec 'FB' do |fbss|
  #     fbss.source_files = 'XBADBase/InterstitialAd/FB/*.swift'
  #     fbss.dependency 'FBAudienceNetwork'
  #     fbss.dependency 'XBADBaseDemo/InterstitialAd/Core'
  #   end
  #   ss.subspec 'Admob' do |admobss|
  #     admobss.source_files = 'XBADBase/InterstitialAd/Admob/*.swift'
  #     admobss.dependency  'Google-Mobile-Ads-SDK', '7.48.0'
  #     admobss.dependency 'XBADBaseDemo/InterstitialAd/Core'
  #   end
  #   ss.subspec 'AppLovin' do |alss|
  #     alss.source_files = 'XBADBase/InterstitialAd/AppLovin/*.swift'
  #     alss.dependency 'AppLovinSDK', '6.11.1'
  #     alss.dependency 'XBADBaseDemo/InterstitialAd/Core'
  #   end
  #   ss.subspec 'MTG' do |mtgss|
  #     mtgss.source_files = 'XBADBase/InterstitialAd/MTG/*.swift'
  #     mtgss.dependency 'MintegralAdSDK/InterstitialVideoAd', '5.8.8.0'
  #     mtgss.dependency 'XBADBaseDemo/InterstitialAd/Core'
  #   end
  # end
end
