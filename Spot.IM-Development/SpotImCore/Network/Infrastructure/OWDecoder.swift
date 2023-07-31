//
//  OWDecoder.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 31/07/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

class OWDecoder {
    static let `default`: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}
