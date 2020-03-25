#
#  Be sure to run `pod spec lint XB_FBAD.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "XB_FBAD"
  spec.version      = "0.0.1"
  spec.summary      = "XB_FBAD for FB"

  spec.description  = <<-DESC
  测试私有库
  主要是FB的AD功能
                   DESC

  spec.homepage     = "https://github.com/quanliangswift/XBADBaseDemo"
  
  spec.license      = "MIT"
  
  spec.author             = { "全亮" => "quanliangani@gmail.com" }
  
  spec.platform     = :ios, "10.1"


  spec.source       = { :git => "https://github.com/quanliangswift/XBADBaseDemo.git", :tag => "#{spec.version}" }


  spec.swift_versions = ['5.0', '5.1']
  spec.source_files = 'XB_FBAD/*.swift'

  spec.frameworks = 'UIKit', 'Foundation'
  

end
