#
#  Be sure to run `pod spec lint XBADBaseDemo.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "XBADBaseDemo"
  spec.version      = "0.0.1.8"
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

  spec.subspec 'Core' do |ss|
  ss.source_files = 'XBADBase/Core/*.swift'
  end

  spec.subspec 'Native' do |ss|
    ss.subspec 'FB' do |fbss|
      fbss.source_files = 'XBADBase/Native/FB/*.swift'
    end
    ss.subspec 'Admob' do |admobss|
      admobss.source_files = 'XBADBase/Native/Admob/*.swift'
    end
    ss.subspec 'Appnext' do |appnextss|
      appnextss.source_files = 'XBADBase/Native/Appnext/*.swift'
    end
    ss.subspec 'Baidu' do |baiduss|
      baiduss.source_files = 'XBADBase/Native/Baidu/*.swift'
    end
    ss.subspec 'MTG' do |mtgss|
      mtgss.source_files = 'XBADBase/Native/MTG/*.swift'
    end
  end

  spec.subspec 'RewardVideo' do |ss|
    ss.subspec 'FB' do |fbss|
      fbss.source_files = 'XBADBase/RewardVideo/FB/*.swift'
      fbss.dependency 'FBAudienceNetwork'
    end
    ss.subspec 'Admob' do |admobss|
      admobss.source_files = 'XBADBase/RewardVideo/Admob/*.swift'
    end
    ss.subspec 'Appnext' do |appnextss|
      appnextss.source_files = 'XBADBase/RewardVideo/Appnext/*.swift'
    end
    ss.subspec 'Baidu' do |baiduss|
      baiduss.source_files = 'XBADBase/RewardVideo/Baidu/*.swift'
    end
    ss.subspec 'MTG' do |mtgss|
      mtgss.source_files = 'XBADBase/RewardVideo/MTG/*.swift'
    end
  end

  spec.subspec 'InterstitialAd' do |ss|
    ss.subspec 'FB' do |fbss|
      fbss.source_files = 'XBADBase/InterstitialAd/FB/*.swift'
    end
    ss.subspec 'Admob' do |admobss|
      admobss.source_files = 'XBADBase/InterstitialAd/Admob/*.swift'
    end
    ss.subspec 'Appnext' do |appnextss|
      appnextss.source_files = 'XBADBase/InterstitialAd/Appnext/*.swift'
    end
    ss.subspec 'Baidu' do |baiduss|
      baiduss.source_files = 'XBADBase/InterstitialAd/Baidu/*.swift'
    end
    ss.subspec 'MTG' do |mtgss|
      mtgss.source_files = 'XBADBase/InterstitialAd/MTG/*.swift'
    end
  end
end
