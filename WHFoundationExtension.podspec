#
#  Be sure to run `pod spec lint FoundationExtension.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "WHFoundationExtension"
  spec.version      = "0.0.4"
  spec.summary      = "A extension of foundation framework."
  
  spec.homepage     = "https://github.com/harleyAnHui/WHFoundationExtension"

  spec.license      = "MIT"

  spec.author             = { "wenhui_wang" => "szwangwh@icloud.com" }
 
  spec.platform     = :ios, "13.0"

  spec.source       = { :git => "git@github.com:harleyAnHui/WHFoundationExtension.git", :tag => "0.0.4" }

  spec.source_files  = "WHFoundationExtension/Source/**/*.swift"

  # spec.vendored_frameworks = 'WHFoundationExtension/WHFoundationExtension.framework'

  # spec.public_header_files = "WHFoundationExtension/WHFoundationExtension.framework/Headers/*.h"

  #依赖库
  spec.framework  = "Foundation"

  #依赖的第三方库
  #spec.dependency "AFNetworking"

  spec.swift_versions = "5.0"

end
