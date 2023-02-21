//
//  OWHelpers.swift
//  SpotImCore
//
//  Created by Alon Haiut on 20/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public protocol OWHelpers {
    func conversationCounters(forPostIds postIds: [OWPostId],
                              completion: OWConversationCountersCompletion)
    var additionalConfigurations: [OWAdditionalConfiguration] { get set }
    var loggerConfiguration: OWLoggerConfiguration { get }
}
#else
protocol OWHelpers {
    func conversationCounters(forPostIds postIds: [OWPostId],
                              completion: OWConversationCountersCompletion)
    var additionalConfigurations: [OWAdditionalConfiguration] { get set }
    var loggerConfiguration: OWLoggerConfiguration { get }
}
#endif
