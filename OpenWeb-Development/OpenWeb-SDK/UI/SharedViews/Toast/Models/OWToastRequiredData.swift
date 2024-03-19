//
//  OWToastRequiredData.swift
//  OpenWebSDK
//
//  Created by  Nogah Melamed on 20/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

struct OWToastRequiredData: Codable, Equatable {
    var type: OWToastType
    var action: OWToastAction
    var title: String
    var bottomPadding: CGFloat = 114
}
