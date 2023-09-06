//
//  OWToastRequiredData.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 20/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

struct OWToastRequiredData {
    var type: OWToastType
    var action: OWToastAction
    var title: String
}

enum OWToastType {
    case information
    case success
    case error
    case warning
}

// TODO: should have some onClick function (except none)
enum OWToastAction: String, OWMenuTypeProtocol {
    case undo
    case tryAgain
    case learnMore
    case close
    case none
}
