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
    func preConversation(postId: String, article: OWArticleProtocol,
                         presentationalMode: OWPresentationalMode,
                         additionalSettings: OWPreConversationSettingsProtocol?,
                         callbacks: OWViewActionsCallbacks?,
                         completion: @escaping OWViewDynamicSizeCompletion)
    
    func conversation(postId: String, article: OWArticleProtocol,
                      presentationalMode: OWPresentationalMode,
                      additionalSettings: OWConversationSettingsProtocol?,
                      callbacks: OWViewActionsCallbacks?,
                      completion: @escaping OWDefaultCompletion)
    
    func commentCreation(postId: String, article: OWArticleProtocol,
                         presentationalMode: OWPresentationalMode,
                         additionalSettings: OWCommentCreationSettingsProtocol?,
                         callbacks: OWViewActionsCallbacks?,
                         completion: @escaping OWDefaultCompletion)
}
#else
protocol OWUIFlows {
    
}
#endif
