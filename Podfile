platform :ios, '15.0'
inhibit_all_warnings!
use_frameworks!

def openweb_pod
  pod 'OpenWebSDK', '2.11.3'
end

def combine_pods
  pod 'CombineCocoa', '0.4.1'
  pod 'CombineExt', '1.8.0'
  pod 'CombineDataSources', '0.2.5'
end

def general_pods
  pod 'SnapKit', '~> 5.7.1'
  pod 'Alamofire', '~> 5.10.1'
end

target 'OpenWeb-SampleApp' do
  openweb_pod
  combine_pods
  general_pods
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
    end
  end
end
