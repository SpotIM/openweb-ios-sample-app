//
//  OWUIFlows.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public protocol OWUIFlows {
    func preConversation(postId: OWPostId,
                         article: OWArticleProtocol,
                         presentationalMode: OWPresentationalMode,
                         additionalSettings: OWPreConversationSettingsProtocol?,
                         callbacks: OWViewActionsCallbacks?,
                         completion: @escaping OWViewCompletion)

    func conversation(postId: OWPostId,
                      article: OWArticleProtocol,
                      presentationalMode: OWPresentationalMode,
                      additionalSettings: OWConversationSettingsProtocol?,
                      callbacks: OWViewActionsCallbacks?,
                      completion: @escaping OWDefaultCompletion)

    func commentCreation(postId: OWPostId,
                         article: OWArticleProtocol,
                         presentationalMode: OWPresentationalMode,
                         additionalSettings: OWCommentCreationSettingsProtocol?,
                         callbacks: OWViewActionsCallbacks?,
                         completion: @escaping OWDefaultCompletion)

    func commentThread(postId: OWPostId,
                       article: OWArticleProtocol,
                       commentId: OWCommentId,
                       presentationalMode: OWPresentationalMode,
                       additionalSettings: OWCommentThreadSettingsProtocol?,
                       callbacks: OWViewActionsCallbacks?,
                       completion: @escaping OWDefaultCompletion)

    func reportReason(commentId: OWCommentId,
                      presentationalMode: OWPresentationalMode,
                      additionalSettings: OWReportReasonSettingsProtocol?,
                      callbacks: OWViewActionsCallbacks?,
                      completion: @escaping OWDefaultCompletion)

#if BETA
    func testingPlayground(postId: OWPostId,
                           presentationalMode: OWPresentationalMode,
                           additionalSettings: OWTestingPlaygroundSettingsProtocol?,
                           callbacks: OWViewActionsCallbacks?,
                           completion: @escaping OWDefaultCompletion)
#endif
}
#else
protocol OWUIFlows {
    func preConversation(postId: OWPostId,
                         article: OWArticleProtocol,
                         presentationalMode: OWPresentationalMode,
                         additionalSettings: OWPreConversationSettingsProtocol?,
                         callbacks: OWViewActionsCallbacks?,
                         completion: @escaping OWViewCompletion)

    func conversation(postId: OWPostId,
                      article: OWArticleProtocol,
                      presentationalMode: OWPresentationalMode,
                      additionalSettings: OWConversationSettingsProtocol?,
                      callbacks: OWViewActionsCallbacks?,
                      completion: @escaping OWDefaultCompletion)

    func commentCreation(postId: OWPostId, article: OWArticleProtocol,
                         presentationalMode: OWPresentationalMode,
                         additionalSettings: OWCommentCreationSettingsProtocol?,
                         callbacks: OWViewActionsCallbacks?,
                         completion: @escaping OWDefaultCompletion)

    func commentThread(postId: OWPostId,
                       article: OWArticleProtocol,
                       commentId: OWCommentId,
                       presentationalMode: OWPresentationalMode,
                       additionalSettings: OWCommentThreadSettingsProtocol?,
                       callbacks: OWViewActionsCallbacks?,
                       completion: @escaping OWDefaultCompletion)
}
#endif
