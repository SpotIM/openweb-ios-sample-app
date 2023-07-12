//
//  OWCommentDeleteAlert.swift
//  SpotImCore
//
//  Created by Alon Shprung on 28/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

enum OWCommentDeleteAlert: String, OWMenuTypeProtocol {
    var identifier: String {
        return self.rawValue
    }

    case delete
    case cancel
}
