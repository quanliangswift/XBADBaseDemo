#
#  Be sure to run `pod spec lint XBADBaseDemo.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "XBADBaseDemo"
  spec.version      = "0.0.1.5"
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
  spec.source_files = 'XBADBase/*.swift'

  spec.frameworks = 'UIKit', 'Foundation'

  spec.dependency "SwiftyJSON"


  # spec.subspec 'XB_FBAD' do |ss|
  # ss.dependency "XBFBAD"
  # end

end
