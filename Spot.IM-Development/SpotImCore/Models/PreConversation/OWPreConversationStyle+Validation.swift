//
//  OWPreConversationStyle+Validation.swift
//  SpotImCore
//
//  Created by Alon Haiut on 31/01/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

extension OWPreConversationStyle {
    func validate() -> OWPreConversationStyle {
        guard case let .regular(numberOfComments) = self else { return self }
        if (numberOfComments > Metrics.maxNumberOfComments) || (numberOfComments < Metrics.minNumberOfComments) {
            return .regular()
        } else {
            return self
        }
    }
}
