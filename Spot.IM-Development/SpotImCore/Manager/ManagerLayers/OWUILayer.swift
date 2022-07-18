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
    
    fileprivate let sdkCoordinator: OWSDKCoordinator
    
    init(sdkCoordinator: OWSDKCoordinator = OWSDKCoordinator()) {
        self.sdkCoordinator = sdkCoordinator
    }
    
    /*
     The below is an example of a function which will be here and also in OWUIFlows protocol.
     We still need to complete a lof of stuff before, however I leave it here intentionally as a reference.
    */
    /*
    func conversation(postId: String, article: OWArticleProtocol,
     presentationalMode: OWPresentationalMode,
     additionalSettings: OWConversationSettingsProtocol? = nil,
     callbacks: @escaping OWViewActionsCallbacks? = nil,
                      completion: @escaping OWDefaultCompletion) {
        
    }
    */
}
