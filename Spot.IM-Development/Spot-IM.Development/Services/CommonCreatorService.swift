//
//  CommonCreatorService.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 28/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import SpotImCore

#if NEW_API

protocol CommonCreatorServicing {
    // Create the following things according to the persistence
    func additionalSettings() -> OWAdditionalSettingsProtocol
    func commentThreadCommentId() -> String
    func mockArticle() -> OWArticleProtocol
}

class CommonCreatorService: CommonCreatorServicing {
    fileprivate let userDefaultsProvider: UserDefaultsProviderProtocol

    init(userDefaultsProvider: UserDefaultsProviderProtocol = UserDefaultsProvider.shared) {
        self.userDefaultsProvider = userDefaultsProvider
    }

    func additionalSettings() -> OWAdditionalSettingsProtocol {
        let preConversationStyle = self.userDefaultsProvider.get(key: .preConversationStyle, defaultValue: OWPreConversationStyle.default)
        let preConversationSettings = OWPreConversationSettingsBuilder(style: preConversationStyle).build()

        let conversationStyle = self.userDefaultsProvider.get(key: .conversationStyle, defaultValue: OWConversationStyle.default)
        let conversationSettings = OWConversationSettingsBuilder(style: conversationStyle).build()

        let additionalSettings = OWAdditionalSettingsBuilder(preConversationSettings: preConversationSettings, fullConversationSettings: conversationSettings)
            .build()
        return additionalSettings
    }

    func commentThreadCommentId() -> String {
        return self.userDefaultsProvider.get(key: .openCommentId, defaultValue: OWCommentThreadSettings.defaultCommentId)
    }

    func mockArticle() -> OWArticleProtocol {
        let articleStub = OWArticle.stub()

        // swiftlint:disable line_length
        let persistenceReadOnlyMode = OWReadOnlyMode.readOnlyMode(fromIndex: self.userDefaultsProvider.get(key: .readOnlyModeIndex, defaultValue: OWReadOnlyMode.defaultIndex))
        // swiftlint:enable line_length
        let settings = OWArticleSettings(section: articleStub.additionalSettings.section,
                                         readOnlyMode: persistenceReadOnlyMode)

        var url = articleStub.url
        if let strURL = self.userDefaultsProvider.get(key: UserDefaultsProvider.UDKey<String>.articleAssociatedURL),
           let persistenceURL = URL(string: strURL) {
            url = persistenceURL
        }

        let article = OWArticle(url: url,
                                title: articleStub.title,
                                subtitle: articleStub.subtitle,
                                thumbnailUrl: articleStub.thumbnailUrl,
                                additionalSettings: settings)
        return article
    }
}

#endif
