//
//  OWReportReasonView-preview.swift
//  OpenWeb-SampleApp
//
//  Created by Yonat Sharon on 04/05/2025.
//

#if DEBUG
@testable import OpenWebSDK
import Combine
import UIKit

class MockSpotConfigurationService: OWSpotConfigurationServicing {
    func spotChanged(spotId: OpenWebCommon.OWSpotId) {}

    func config(spotId: OpenWebCommon.OWSpotId) -> AnyPublisher<OpenWebSDK.SPSpotConfiguration, any Error> {
        let jsonString = """
        {
            "shared": {
                "votesType": "updown",
                "reportReasonsOptions": {
                    "reasons": [
                        {"reportType": "spam", "requiredAdditionalInfo": false},
                        {"reportType": "identity_attack", "requiredAdditionalInfo": false},
                        {"reportType": "hate_speech", "requiredAdditionalInfo": false},
                        {"reportType": "false_information", "requiredAdditionalInfo": true}
                    ]
                },
                "communityGuidelines": "Community guidelines text. Click here to learn more."
            },
            "mobile-sdk": {
                "reportReasonsCounterMaxLength": 280,
                "openwebWebsiteUrl": "https://www.openweb.com",
                "openwebPrivacyUrl": "https://www.openweb.com/privacy-policy",
                "openwebTermsUrl": "https://www.openweb.com/terms-of-use",
                "imageUploadBaseUrl": "https://images.openweb.com",
                "fetchImageBaseUrl": "https://images.openweb.com",
                "enableCommentEditing": true
            }
        }
        """

        do {
            let config = try JSONDecoder().decode(SPSpotConfiguration.self, from: jsonString.data(using: .utf8)!)
            return .just(config)
        } catch {
            print(error)
            return .empty()
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    let reportReasonView = OWReportReasonView(viewModel: OWReportReasonViewViewModel(
        reportData: OWReportReasonsRequiredData(commentId: "comment123", parentId: "parent123", postId: "post123"),
        viewableMode: .partOfFlow,
        presentationalMode: .none,
        servicesProvider: MockServicesProvider(spotConfigurationService: MockSpotConfigurationService())
    ))

    let themeInjectorView = ThemeInjectorView()
    themeInjectorView.addSubview(reportReasonView)
    reportReasonView.OWSnp.makeConstraints { make in
        make.edges.equalToSuperview()
    }

    return themeInjectorView
}

#endif
