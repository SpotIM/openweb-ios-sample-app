//
//  OWHelpersInternal.swift
//  SpotImCore
//
//  Created by Alon Haiut on 20/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

protocol OWHelpersInternalProtocol {
    var shouldSuppressFinmbFilter: Bool { get }
}

class OWHelpersLayer: OWHelpers, OWHelpersInternalProtocol {

    fileprivate var configurations: [OWAdditionalConfiguration] = []

    var shouldSuppressFinmbFilter: Bool {
        return configurations.contains(.suppressFinmbFilter)
    }
}

// Will be public extension
extension OWHelpersLayer {
    func conversationCounters(forPostIds postIds: [OWPostId],
                              completion: OWConversationCountersCompletion) {
        
    }
    
    var additionalConfigurations: [OWAdditionalConfiguration] {
        get {
           return configurations
        }
        set(newConfigurations) {
            configurations = Array(Set(newConfigurations))
        }
    }
}
