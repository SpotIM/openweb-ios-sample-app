//
//  OWNetworkSessionCredentials.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 16/03/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation

struct OWNetworkSessionCredentials: Codable {
    let guid: String?
    let openwebToken: String?
    let authorization: String?
}

extension OWNetworkSessionCredentials {
    static var none: OWNetworkSessionCredentials {
        return OWNetworkSessionCredentials(guid: nil,
                                           openwebToken: nil,
                                           authorization: nil)
    }
}
