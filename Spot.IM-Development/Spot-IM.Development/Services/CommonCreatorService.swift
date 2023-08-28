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
        var commentCreationStyle = self.userDefaultsProvider.get(key: .commentCreationStyle, defaultValue: OWCommentCreationStyle.default)
        // Inject toolbar if needed
        var newToolbarVM: CommentCreationToolbarViewModeling? = nil
        if case OWCommentCreationStyle.floatingKeyboard(let accessoryViewStrategy) = commentCreationStyle,
           case OWAccessoryViewStrategy.bottomToolbar = accessoryViewStrategy {
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
        let commentId = self.userDefaultsProvider.get(key: .openCommentId, defaultValue: OWCommentThreadSettings.defaultCommentId)
        if (commentId.isEmpty) {
            // If value is empty on user defaults, we want to use the default comment ID
            return OWCommentThreadSettings.defaultCommentId
        } else {
            return commentId
        }
    }

    func mockArticle() -> OWArticleProtocol {
        let articleStub = OWArticle.stub()

        let persistenceReadOnlyMode = OWReadOnlyMode.readOnlyMode(fromIndex: self.userDefaultsProvider.get(key: .readOnlyModeIndex,
                                                                                                           defaultValue: OWReadOnlyMode.default.index))
        let persistenceArticleHeaderStyle = self.userDefaultsProvider.get(key: UserDefaultsProvider.UDKey<OWArticleHeaderStyle>.articleHeaderStyle,
                                                                          defaultValue: OWArticleHeaderStyle.default)

        let persistenceArticleInformationStrategy = self.userDefaultsProvider.get(key: UserDefaultsProvider.UDKey<OWArticleInformationStrategy>.articleInformationStrategy,
                                                                          defaultValue: OWArticleInformationStrategy.default)

        let settings = OWArticleSettings(section: articleStub.additionalSettings.section,
                                         headerStyle: persistenceArticleHeaderStyle,
                                         readOnlyMode: persistenceReadOnlyMode)

        var url = persistenceArticleInformationStrategy.url
        if let strURL = self.userDefaultsProvider.get(key: UserDefaultsProvider.UDKey<String>.articleAssociatedURL),
           let persistenceURL = URL(string: strURL) {
            url = persistenceURL
        }

        // TODO: use sampleapp settings for strategy
        let article = OWArticle(
            articleInformationStrategy: persistenceArticleInformationStrategy,
            additionalSettings: settings)
        return article
    }

    func commentCreationFloatingBottomToolbar() -> (CommentCreationToolbarViewModeling, CommentCreationToolbar) {
        let toolbarElements = [
            ToolbarElementModel(emoji: "😍", accessibility: "heart_eyes", action: .append(text: "😍")),
            ToolbarElementModel(emoji: "🔥", accessibility: "fire", action: .append(text: "🔥")),
            ToolbarElementModel(emoji: "❤️", accessibility: "heart", action: .append(text: "❤️")),
            ToolbarElementModel(emoji: "🚀", accessibility: "rocket", action: .append(text: "🚀")),
            ToolbarElementModel(emoji: "🤩", accessibility: "starry_eyes", action: .append(text: "🤩")),
            ToolbarElementModel(emoji: "␡", accessibility: "delete", action: .removeAll)
        ]
        let viewModel: CommentCreationToolbarViewModeling = CommentCreationToolbarViewModel(toolbarElments: toolbarElements)
        let toolbar = CommentCreationToolbar(viewModel: viewModel)
        return (viewModel, toolbar)
    }
}

#endif
