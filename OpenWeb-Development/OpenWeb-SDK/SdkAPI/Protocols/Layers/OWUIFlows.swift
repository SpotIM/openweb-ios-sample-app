//
//  OWUIFlows.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 06/07/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation

public protocol OWUIFlows {
    func preConversation(postId: OWPostId,
                         article: OWArticleProtocol,
                         presentationalMode: OWPresentationalMode,
                         additionalSettings: OWAdditionalSettingsProtocol,
                         callbacks: OWViewActionsCallbacks?,
                         completion: @escaping OWViewCompletion)

    func conversation(postId: OWPostId,
                      article: OWArticleProtocol,
                      presentationalMode: OWPresentationalMode,
                      additionalSettings: OWAdditionalSettingsProtocol,
                      callbacks: OWViewActionsCallbacks?,
                      completion: @escaping OWDefaultCompletion)

    func commentCreation(postId: OWPostId,
                         article: OWArticleProtocol,
                         presentationalMode: OWPresentationalMode,
                         additionalSettings: OWAdditionalSettingsProtocol,
                         callbacks: OWViewActionsCallbacks?,
                         completion: @escaping OWDefaultCompletion)

    func commentThread(postId: OWPostId,
                       article: OWArticleProtocol,
                       commentId: OWCommentId,
                       presentationalMode: OWPresentationalMode,
                       additionalSettings: OWAdditionalSettingsProtocol,
                       callbacks: OWViewActionsCallbacks?,
                       completion: @escaping OWDefaultCompletion)

#if BETA
    func testingPlayground(postId: OWPostId,
                           presentationalMode: OWPresentationalMode,
                           additionalSettings: OWTestingPlaygroundSettingsProtocol,
                           callbacks: OWViewActionsCallbacks?,
                           completion: @escaping OWDefaultCompletion)
#endif

#if AUTOMATION
    func fonts(presentationalMode: OWPresentationalMode,
               additionalSettings: OWAutomationSettingsProtocol,
               callbacks: OWViewActionsCallbacks?,
               completion: @escaping OWDefaultCompletion)

    func userStatus(presentationalMode: OWPresentationalMode,
                    additionalSettings: OWAutomationSettingsProtocol,
                    callbacks: OWViewActionsCallbacks?,
                    completion: @escaping OWDefaultCompletion)
#endif
}
