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
                         additionalSettings: OWPreConversationSettingsProtocol?,
                         callbacks: OWViewActionsCallbacks?,
                         completion: @escaping OWViewCompletion)

    func conversation(postId: OWPostId,
                      article: OWArticleProtocol,
                      additionalSettings: OWConversationSettingsProtocol?,
                      callbacks: OWViewActionsCallbacks?,
                      completion: @escaping OWViewCompletion)
}
#else
protocol OWUIViews {
    func preConversation(postId: OWPostId,
                         article: OWArticleProtocol,
                         additionalSettings: OWPreConversationSettingsProtocol?,
                         callbacks: OWViewActionsCallbacks?,
                         completion: @escaping OWViewCompletion)

    func conversation(postId: OWPostId,
                      article: OWArticleProtocol,
                      additionalSettings: OWConversationSettingsProtocol?,
                      callbacks: OWViewActionsCallbacks?,
                      completion: @escaping OWViewCompletion)
}
#endif
