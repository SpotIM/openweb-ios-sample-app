//
//  OWEncoder.swift
//  OpenWebSDK
//
//  Created by  Nogah Melamed on 31/07/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation

class OWEncoder {
    static let `default`: JSONEncoder = {
        let decoder = JSONEncoder()
        decoder.keyEncodingStrategy = .convertToSnakeCase
        return decoder
    }()
}
