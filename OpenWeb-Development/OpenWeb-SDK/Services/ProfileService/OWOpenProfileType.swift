//
//  OWOpenProfileType.swift
//  OpenWebSDK
//
//  Created by  Nogah Melamed on 10/10/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation

enum OWOpenProfileType {
    case OWProfile(data: OWOpenProfileData)
    case publisherProfile(ssoPublisherId: String, type: OWUserProfileType)
}
