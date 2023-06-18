//
//  OWRxPresenterResponseType.swift
//  SpotImCore
//
//  Created by Alon Shprung on 04/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

enum OWRxPresenterResponseType {
    case completion
    case selected(action: OWRxPresenterAction)
}
