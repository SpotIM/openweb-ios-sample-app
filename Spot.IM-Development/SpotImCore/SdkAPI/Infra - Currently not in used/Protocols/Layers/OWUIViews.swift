//
//  OWUIViews.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public protocol OWUIViews {
    func preConversation(postId: OWPostId,
                         article: OWArticleProtocol,
                         additionalSettings: OWAdditionalSettingsProtocol,
                         callbacks: OWViewActionsCallbacks?,
                         completion: @escaping OWViewCompletion)

    func conversation(postId: OWPostId,
                      article: OWArticleProtocol,
                      additionalSettings: OWAdditionalSettingsProtocol,
                      callbacks: OWViewActionsCallbacks?,
                      completion: @escaping OWViewCompletion)

    func commentCreation(postId: OWPostId,
                         article: OWArticleProtocol,
                         commentCreationType: OWCommentCreationType,
                         additionalSettings: OWAdditionalSettingsProtocol,
                         callbacks: OWViewActionsCallbacks?,
                         completion: @escaping OWViewCompletion)

    func commentThread(postId: OWPostId,
                       article: OWArticleProtocol,
                       commentId: OWCommentId,
                       additionalSettings: OWAdditionalSettingsProtocol,
                       callbacks: OWViewActionsCallbacks?,
                       completion: @escaping OWViewCompletion)

    func reportReason(postId: OWPostId,
                      commentId: OWCommentId,
                      parentId: OWCommentId,
                      additionalSettings: OWAdditionalSettingsProtocol,
                      callbacks: OWViewActionsCallbacks?,
                      completion: @escaping OWViewCompletion)

#if BETA
    func testingPlayground(postId: OWPostId,
                           additionalSettings: OWTestingPlaygroundSettingsProtocol,
                           callbacks: OWViewActionsCallbacks?,
                           completion: @escaping OWViewCompletion)
#endif
}
#else
protocol OWUIViews {
    func preConversation(postId: OWPostId,
                         article: OWArticleProtocol,
                         additionalSettings: OWAdditionalSettingsProtocol,
                         callbacks: OWViewActionsCallbacks?,
                         completion: @escaping OWViewCompletion)

    func conversation(postId: OWPostId,
                      article: OWArticleProtocol,
                      additionalSettings: OWAdditionalSettingsProtocol,
                      callbacks: OWViewActionsCallbacks?,
                      completion: @escaping OWViewCompletion)

    func commentCreation(postId: OWPostId,
                         article: OWArticleProtocol,
                         commentCreationType: OWCommentCreationType,
                         additionalSettings: OWAdditionalSettingsProtocol,
                         callbacks: OWViewActionsCallbacks?,
                         completion: @escaping OWViewCompletion)

    func commentThread(postId: OWPostId,
                       article: OWArticleProtocol,
                       commentId: OWCommentId,
                       additionalSettings: OWAdditionalSettingsProtocol,
                       callbacks: OWViewActionsCallbacks?,
                       completion: @escaping OWViewCompletion)

    func reportReason(postId: OWPostId,
                      commentId: OWCommentId,
                      parentId: OWCommentId,
                      additionalSettings: OWAdditionalSettingsProtocol,
                      callbacks: OWViewActionsCallbacks?,
                      completion: @escaping OWViewCompletion)
}
#endif
