//
//  OWSubmittedVC-preview.swift
//  OpenWeb-SampleApp
//

#if DEBUG
@testable import OpenWebSDK
import Combine
import UIKit

private class PreviewLocalizationManager: OWLocalizationManagerProtocol {
    func localizedString(key: String) -> String { key }
    var locale: Locale { .current }
    var semanticAttribute: UISemanticContentAttribute { .forceLeftToRight }
    var textAlignment: NSTextAlignment { .left }
    var currentLanguage: AnyPublisher<OWSupportedLanguage, Never> { .just(.english) }
}

private class PreviewSpotConfigurationService: StubSpotConfigurationService {
    let isAppealEnabled: Bool
    let isReportAppealEnabled: Bool

    init(isAppealEnabled: Bool, isReportAppealEnabled: Bool) {
        self.isAppealEnabled = isAppealEnabled
        self.isReportAppealEnabled = isReportAppealEnabled
        super.init()
    }

    override func config(spotId: OWSpotId) -> AnyPublisher<SPSpotConfiguration, Error> {
        let jsonString = """
        {
            "mobile-sdk": {
                "enabled": true,
                "openwebWebsiteUrl": "https://www.openweb.com",
                "openwebPrivacyUrl": "https://www.openweb.com/privacy",
                "openwebTermsUrl": "https://www.openweb.com/terms",
                "imageUploadBaseUrl": "https://images.spot.im",
                "fetchImageBaseUrl": "https://images.spot.im"
            },
            "conversation": {
                "isAppealEnabled": \(isAppealEnabled),
                "isReportAppealEnabled": \(isReportAppealEnabled),
                "enableTabs": false,
                "showNotificationsBell": false,
                "statusFetchIntervalInMs": 300,
                "statusFetchTimeoutInMs": 3000,
                "statusFetchRetryCount": 12
            }
        }
        """
        let jsonData = Data(jsonString.utf8)
        do {
            let config = try OWDecoder.default.decode(SPSpotConfiguration.self, from: jsonData)
            return .just(config)
        } catch {
            print(error)
            return .error(error)
        }
    }
}

@available(iOS 17.0, *)
#Preview("Report Reason - Standard") {
    let configService = PreviewSpotConfigurationService(isAppealEnabled: false, isReportAppealEnabled: false)
    let servicesProvider = MockServicesProvider(spotConfigurationService: configService)
    let viewModel = OWSubmittedViewViewModel(type: .reportReason, servicesProvider: servicesProvider, localizationManager: PreviewLocalizationManager())
    return OWSubmittedVC(submittedViewViewModel: viewModel)
}

@available(iOS 17.0, *)
#Preview("Report Reason - Appeal Enabled") {
    let configService = PreviewSpotConfigurationService(isAppealEnabled: true, isReportAppealEnabled: true)
    let servicesProvider = MockServicesProvider(spotConfigurationService: configService)
    let viewModel = OWSubmittedViewViewModel(type: .reportReason, servicesProvider: servicesProvider, localizationManager: PreviewLocalizationManager())
    return OWSubmittedVC(submittedViewViewModel: viewModel)
}

@available(iOS 17.0, *)
#Preview("Commenter Appeal Submitted") {
    let viewModel = OWSubmittedViewViewModel(type: .commenterAppeal, localizationManager: PreviewLocalizationManager())
    return OWSubmittedVC(submittedViewViewModel: viewModel)
}

private class PreviewSpotConfigurationServiceWithOverrides: StubSpotConfigurationService {
    override func config(spotId: OWSpotId) -> AnyPublisher<SPSpotConfiguration, Error> {
        let jsonString = """
        {
            "mobile-sdk": {
                "enabled": true,
                "openwebWebsiteUrl": "https://www.openweb.com",
                "openwebPrivacyUrl": "https://www.openweb.com/privacy",
                "openwebTermsUrl": "https://www.openweb.com/terms",
                "imageUploadBaseUrl": "https://images.spot.im",
                "fetchImageBaseUrl": "https://images.spot.im"
            },
            "conversation": {
                "isAppealEnabled": false,
                "isReportAppealEnabled": false,
                "enableTabs": false,
                "showNotificationsBell": false,
                "statusFetchIntervalInMs": 300,
                "statusFetchTimeoutInMs": 3000,
                "statusFetchRetryCount": 12
            },
            "standalone-ui-kit": {
                "translation_text_overrides": {
                    "en": {
                        "report-reasons-modal": {
                            "submitted": {
                                "title": "Custom Thank You!",
                                "button": "Custom Done",
                                "description": "Custom appeal description",
                                "standardDescription": "Custom standard description"
                            }
                        }
                    }
                }
            }
        }
        """
        let jsonData = Data(jsonString.utf8)
        do {
            let config = try OWDecoder.default.decode(SPSpotConfiguration.self, from: jsonData)
            return .just(config)
        } catch {
            print(error)
            return .error(error)
        }
    }
}

@available(iOS 17.0, *)
#Preview("Report Reason - With Overrides") {
    let configService = PreviewSpotConfigurationServiceWithOverrides()
    let servicesProvider = MockServicesProvider(spotConfigurationService: configService)
    let viewModel = OWSubmittedViewViewModel(type: .reportReason, servicesProvider: servicesProvider, localizationManager: PreviewLocalizationManager())
    return OWSubmittedVC(submittedViewViewModel: viewModel)
}

#endif
