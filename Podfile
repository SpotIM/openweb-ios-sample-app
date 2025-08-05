platform :ios, '15.0'
inhibit_all_warnings!
use_frameworks!

def openweb_pod
  pod 'OpenWebSDK', '2.9.1'
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

# Setting `BUILD_LIBRARY_FOR_DISTRIBUTION` to `YES` in the host application for Rx dependencies.
# This step is required for `OpenWebSDK.xcframework` to find symbols of the Rx dependencies at runtime.
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
      if target.name == "RxSwift" || target.name == "RxCocoa" || target.name == "RxRelay"
        config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
      end
    end
  end
end
