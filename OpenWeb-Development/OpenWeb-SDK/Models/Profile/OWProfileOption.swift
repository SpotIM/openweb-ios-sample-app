//
//  OWProfileOption.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 02/05/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation

enum OWProfileOption: Equatable {
    case none
    case SDKProfile
    case publisherProfile(ssoPublisherId: String)
}
