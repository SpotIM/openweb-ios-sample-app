//
//  CommonCreatorService.swift
//  OpenWeb-Development
//
//  Created by Alon Haiut on 28/03/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import UIKit
import Combine
import OpenWebSDK
#if !PUBLIC_DEMO_APP
import OpenWeb_SampleApp_Internal_Configs
#endif

protocol CommonCreatorServicing {
    // Create the following things according to the persistence
    func additionalSettings() -> OWAdditionalSettingsProtocol
    func commentThreadCommentId() -> String
    func mockArticle(for postId: String) -> OWArticleProtocol
    var renewSSOCallback: OWRenewSSOCallback { get }
}

class CommonCreatorService: CommonCreatorServicing {
    private let userDefaultsProvider: UserDefaultsProviderProtocol
    private let silentSSOAuthentication: SilentSSOAuthenticationNewAPIProtocol
    private var cancellables = Set<AnyCancellable>()

    init(userDefaultsProvider: UserDefaultsProviderProtocol = UserDefaultsProvider.shared,
         silentSSOAuthentication: SilentSSOAuthenticationNewAPIProtocol = SilentSSOAuthenticationNewAPI()) {
        self.userDefaultsProvider = userDefaultsProvider
        self.silentSSOAuthentication = silentSSOAuthentication
    }

    func additionalSettings() -> OWAdditionalSettingsProtocol {
        let allowPullToRefresh = self.userDefaultsProvider.get(key: .allowPullToRefresh, defaultValue: true)

        // 1. Pre conversation related
        let preConversationStyle = self.userDefaultsProvider.get(key: .preConversationStyle, defaultValue: OWPreConversationStyle.default)
        let preConversationSettings = OWPreConversationSettingsBuilder(style: preConversationStyle).build()

        // 2. Conversation related
        let conversationStyle = self.userDefaultsProvider.get(key: .conversationStyle, defaultValue: OWConversationStyle.default)
        let conversationSettings = OWConversationSettings(style: conversationStyle, allowPullToRefresh: allowPullToRefresh)

        // 3. Comment creation related
        let commentCreationStyle = self.userDefaultsProvider.get(key: .commentCreationStyle, defaultValue: OWCommentCreationStyle.default)
        let commentCreationSettings = OWCommentCreationSettingsBuilder(style: commentCreationStyle).build()

        // 4. Comment thread related
        let commentThreadSettings = OWCommentThreadSettings(allowPullToRefresh: allowPullToRefresh)

        // 5. Final additional settings
        let additionalSettings = OWAdditionalSettingsBuilder(
            preConversationSettings: preConversationSettings,
            fullConversationSettings: conversationSettings,
            commentCreationSettings: commentCreationSettings,
            commentThreadSettings: commentThreadSettings
        ).build()
        return additionalSettings
    }

    func commentThreadCommentId() -> String {
        let commentId = self.userDefaultsProvider.get(key: .openCommentId, defaultValue: OWCommentThreadSettings.defaultCommentId)
        if commentId.isEmpty {
            // If value is empty on user defaults, we want to use the default comment ID
            return OWCommentThreadSettings.defaultCommentId
        } else {
            return commentId
        }
    }

    func mockArticle(for postId: String) -> OWArticleProtocol {
        let persistenceReadOnlyMode = OWReadOnlyMode.readOnlyMode(fromIndex: self.userDefaultsProvider.get(key: .readOnlyModeIndex,
                                                                                                           defaultValue: OWReadOnlyMode.default.index))
        let persistenceArticleHeaderStyle = self.userDefaultsProvider.get(key: UserDefaultsProvider.UDKey<OWArticleHeaderStyle>.articleHeaderStyle,
                                                                          defaultValue: OWArticleHeaderStyle.default)

        var persistenceArticleInformationStrategy = self.userDefaultsProvider.get(key: UserDefaultsProvider.UDKey<OWArticleInformationStrategy>.articleInformationStrategy,
                                                                          defaultValue: OWArticleInformationStrategy.default)

        var section = self.userDefaultsProvider.get(key: UserDefaultsProvider.UDKey<String?>.articleSection,
                                                                          defaultValue: nil)
        if section == nil || section?.isEmpty == true {
            section = self.getSectionFromPreset(for: postId)
        }

        let starRatingEnabled = self.userDefaultsProvider.get(key: UserDefaultsProvider.UDKey<Bool>.starRatingEnabled,
                                                              defaultValue: false)
        let settings = OWArticleSettings(section: section ?? "",
                                         headerStyle: persistenceArticleHeaderStyle,
                                         readOnlyMode: persistenceReadOnlyMode,
                                         starRatingEnabled: starRatingEnabled)

        if let strURL = self.userDefaultsProvider.get(key: UserDefaultsProvider.UDKey<String>.articleAssociatedURL),
           let persistenceURL = URL(string: strURL),
           case .local(let data) = persistenceArticleInformationStrategy {
            let extraData = OWArticleExtraData(url: persistenceURL, title: data.title, subtitle: data.subtitle, thumbnailUrl: data.thumbnailUrl)
            persistenceArticleInformationStrategy = .local(data: extraData)
        }

        let article = OWArticle(
            articleInformationStrategy: persistenceArticleInformationStrategy,
            additionalSettings: settings)
        return article
    }

    func getSectionFromPreset(for spotId: String) -> String? {
        let presets = ConversationPreset.createMockModels()
        let presetForSpot = presets.first(where: { $0.conversationDataModel.spotId == spotId })
        return presetForSpot?.section
    }

    lazy var renewSSOCallback: OWRenewSSOCallback = { [weak self] userId, completion in
        guard let self else { return }
            #if !PUBLIC_DEMO_APP
            let demoSpotId = DevelopmentConversationPreset.demoSpot().toConversationPreset().conversationDataModel.spotId
            if OpenWeb.manager.spotId == demoSpotId,
               let genericSSO = GenericSSOAuthentication.mockModels.first(where: { $0.user.userId == userId }) {
                self.silentSSOAuthentication.silentSSO(for: genericSSO, ignoreLoginStatus: true)
                    .prefix(1)
                    .sink(receiveCompletion: { result in
                        if case .failure(let error) = result {
                            DLog("Silent SSO failed with error: \(error)")
                            completion()
                        }
                    }, receiveValue: { userId in
                        DLog("Silent SSO completed successfully with userId: \(userId)")
                        completion()
                    })
                    .store(in: &cancellables)
            } else {
                DLog("`renewSSOCallback` triggered, but this is not our demo spot: \(demoSpotId)")
                completion()
            }
            #else
            DLog("`renewSSOCallback` triggered")
            completion()
            #endif
    }
}
