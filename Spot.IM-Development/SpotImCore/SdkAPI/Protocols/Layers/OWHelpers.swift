//
//  OWHelpers.swift
//  SpotImCore
//
//  Created by Alon Haiut on 20/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

public protocol OWHelpers {
    func conversationCounters(forPostIds postIds: [OWPostId],
                              completion: @escaping OWConversationCountersCompletion)
    var additionalConfigurations: [OWAdditionalConfiguration] { get set }
    var loggerConfiguration: OWLoggerConfiguration { get }
    var languageStrategy: OWLanguageStrategy { get set }
    var localeStrategy: OWLocaleStrategy { get set } // Will be use for Dates and Numbers format
    var orientationEnforcement: OWOrientationEnforcement { get set }
}
