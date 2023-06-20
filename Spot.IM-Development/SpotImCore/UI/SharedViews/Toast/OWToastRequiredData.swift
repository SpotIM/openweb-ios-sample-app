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
}

// TODO: should have some onClick function (except none)
enum OWToastAction {
    case undo
    case tryAgain
    case learnMore
    case none
}
