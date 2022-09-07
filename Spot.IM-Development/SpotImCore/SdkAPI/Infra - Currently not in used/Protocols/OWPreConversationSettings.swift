//
//  OWPreConversationSettings.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 07/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

protocol OWPreConversationSettingsProtocol {
    var numberOfComments: Int { get set }
}

struct OWPreConversationSettings: OWPreConversationSettingsProtocol {
    var numberOfComments: Int
}
