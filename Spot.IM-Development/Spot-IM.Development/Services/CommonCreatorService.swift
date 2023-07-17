//
//  CommonCreatorService.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 28/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import SpotImCore

#if NEW_API

protocol CommonCreatorServicing {
    // Create the following things according to the persistence
    func additionalSettings() -> OWAdditionalSettingsProtocol
    func commentThreadCommentId() -> String
    func mockArticle() -> OWArticleProtocol
    func commentCreationFloatingBottomToolbar() -> (CommentCreationToolbarViewModeling, CommentCreationToolbar)
}

class CommonCreatorService: CommonCreatorServicing {
    fileprivate let userDefaultsProvider: UserDefaultsProviderProtocol

    init(userDefaultsProvider: UserDefaultsProviderProtocol = UserDefaultsProvider.shared) {
        self.userDefaultsProvider = userDefaultsProvider
    }

    func additionalSettings() -> OWAdditionalSettingsProtocol {
        // 1. Pre conversation related
        let preConversationStyle = self.userDefaultsProvider.get(key: .preConversationStyle, defaultValue: OWPreConversationStyle.default)
        let preConversationSettings = OWPreConversationSettingsBuilder(style: preConversationStyle).build()

        // 2. Conversation related
        let conversationStyle = self.userDefaultsProvider.get(key: .conversationStyle, defaultValue: OWConversationStyle.default)
        let conversationSettings = OWConversationSettingsBuilder(style: conversationStyle).build()

        // 3. Comment creation related
        var commentCreationStyle = self.userDefaultsProvider.get(key: .commentCreationStyle, defaultValue: OWCommentCreationStyle.regular)
        // Inject toolbar if needed
        var newToolbarVM: CommentCreationToolbarViewModeling? = nil
        if case let OWCommentCreationStyle.floatingKeyboard(accessoryViewStrategy) = commentCreationStyle,
           case OWAccessoryViewStrategy.bottomToolbar(_) = accessoryViewStrategy {
            // Since we can't actually save the toolbar UIView in the memory, we will re-create it
            let floatingBottomToolbarTuple = self.commentCreationFloatingBottomToolbar()
            let newToolbar = floatingBottomToolbarTuple.1
            newToolbarVM = floatingBottomToolbarTuple.0
            let newAccessoryViewStrategy = OWAccessoryViewStrategy.bottomToolbar(toolbar: newToolbar)
            commentCreationStyle = OWCommentCreationStyle.floatingKeyboard(accessoryViewStrategy: newAccessoryViewStrategy)
        }
        let commentCreationSettings = OWCommentCreationSettingsBuilder(style: commentCreationStyle).build()
        // Inject the settings into the toolbar VM if such exist
        newToolbarVM?.inputs.setCommentCreationSettings(commentCreationSettings)

        // 4. Comment thread related
        let commentThreadSettings = OWCommentThreadSettingsBuilder().build()

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
        return self.userDefaultsProvider.get(key: .openCommentId, defaultValue: OWCommentThreadSettings.defaultCommentId)
    }

    func mockArticle() -> OWArticleProtocol {
        let articleStub = OWArticle.stub()

        let persistenceReadOnlyMode = OWReadOnlyMode.readOnlyMode(fromIndex: self.userDefaultsProvider.get(key: .readOnlyModeIndex,
                                                                                                           defaultValue: OWReadOnlyMode.defaultIndex))
        let persistenceArticleHeaderStyle = self.userDefaultsProvider.get(key: UserDefaultsProvider.UDKey<OWArticleHeaderStyle>.articleHeaderStyle,
                                                                          defaultValue: OWArticleHeaderStyle.default)

        let settings = OWArticleSettings(section: articleStub.additionalSettings.section,
                                         headerStyle: persistenceArticleHeaderStyle,
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

    func commentCreationFloatingBottomToolbar() -> (CommentCreationToolbarViewModeling, CommentCreationToolbar) {
        let toolbarElements = [
            ToolbarElementModel(emoji: "😍", action: .append(text: "😍")),
            ToolbarElementModel(emoji: "🔥", action: .append(text: "🔥")),
            ToolbarElementModel(emoji: "❤️", action: .append(text: "❤️")),
            ToolbarElementModel(emoji: "🚀", action: .append(text: "🚀")),
            ToolbarElementModel(emoji: "🤩", action: .append(text: "🤩")),
            ToolbarElementModel(emoji: "␡", action: .removeAll)
        ]
        let viewModel: CommentCreationToolbarViewModeling = CommentCreationToolbarViewModel(toolbarElments: toolbarElements)
        let toolbar = CommentCreationToolbar(viewModel: viewModel)
        return (viewModel, toolbar)
    }
}

#endif
