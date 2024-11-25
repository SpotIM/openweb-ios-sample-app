#
# Be sure to run `pod lib lint OpenWebIAU.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'OpenWebIAU'
  s.version          = '1.3.0'
  s.swift_versions   = ['5.0']
  s.summary          = 'OpenWeb IAU SDK'
  s.description      = 'This SDK allows you to integrate OpenWeb IAU into your iOS app.'
  s.homepage         = "https://www.openweb.com"
  s.license          = { :type => 'CUSTOM', :file => 'LICENSE' }
  s.author           = { 'Alon Haiut' => 'alon.h@openweb.com' }
  s.platform         = :ios
  s.ios.deployment_target = '13.0'

  s.static_framework = true # needed because of Google-Mobile-Ads-SDK. Fixes the error: "target has transitive dependencies that include statically linked binaries"

  # Setting pod `BUILD_LIBRARY_FOR_DISTRIBUTION` to `YES`
  s.pod_target_xcconfig = { 'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES' }

  # the Pre-Compiled Framework:
  s.source          = { :git => 'https://github.com/SpotIM/openweb-ios-iau-sdk-pod.git', :tag => s.version.to_s }
  s.ios.vendored_frameworks = 'KmmSpotimStandaloneAd.xcframework', 'OpenWebIAUSDK.xcframework'

  # Dependencies
  s.dependency 'AdPlayerSDK', '~> 1.11.9'
  s.dependency 'OpenWrapSDK', '3.6.0'
  s.dependency 'OpenWrapHandlerDFP', '5.0.0'
  s.dependency 'AppHarbrSDK', '~> 1.14.0'
  s.dependency 'Google-Mobile-Ads-SDK', '~> 11.5.0'
  s.dependency 'NimbusSDK', '~> 2.20.0'
  s.dependency 'NimbusSDK/NimbusKit'
  s.dependency 'NimbusSDK/NimbusRenderStaticKit'
  s.dependency 'NimbusSDK/NimbusGAMKit'

end