//
//  OWUILayer.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

class OWUILayer: OWUI, OWUIFlows, OWUIViews {
    var flows: OWUIFlows { return self }
    var views: OWUIViews { return self }
    var helpers: OWHelpers { return self._helpers }
    
    fileprivate let sdkCoordinator: OWSDKCoordinator
    fileprivate let _helpers: OWHelpers
    
    init(sdkCoordinator: OWSDKCoordinator = OWSDKCoordinator(),
        helpers: OWHelpers = OWHelpersInternal()) {
        self.sdkCoordinator = sdkCoordinator
        self._helpers = helpers
    }
    
    func preConversation(postId: String, article: OWArticleProtocol,
     presentationalMode: OWPresentationalMode,
     additionalSettings: OWPreConversationSettingsProtocol? = nil,
     callbacks: OWViewActionsCallbacks? = nil,
                         completion: @escaping OWViewDynamicSizeCompletion) {
        
    }
    
    func conversation(postId: String, article: OWArticleProtocol,
     presentationalMode: OWPresentationalMode,
     additionalSettings: OWConversationSettingsProtocol? = nil,
     callbacks: OWViewActionsCallbacks? = nil,
                      completion: @escaping OWDefaultCompletion) {
        
    }
    
    func commentCreation(postId: String, article: OWArticleProtocol,
     presentationalMode: OWPresentationalMode,
     additionalSettings: OWCommentSettingsProtocol? = nil,
     callbacks: OWViewActionsCallbacks? = nil,
                 completion: @escaping OWDefaultCompletion) {
        
    }
}
