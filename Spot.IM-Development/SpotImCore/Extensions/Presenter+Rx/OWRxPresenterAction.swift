//
//  OWRxPresenterAction.swift
//  SpotImCore
//
//  Created by Alon Shprung on 04/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

struct OWRxPresenterAction: Equatable {
    var uuid: String = UUID().uuidString
    let title: String
    let type: OWMenuTypeProtocol
    var style: UIAlertAction.Style = .default
}

extension OWRxPresenterAction {
    static func == (lhs: OWRxPresenterAction, rhs: OWRxPresenterAction) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}
