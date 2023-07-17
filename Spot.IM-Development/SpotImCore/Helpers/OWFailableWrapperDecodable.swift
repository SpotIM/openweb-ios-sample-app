//
//  OWFailableWrapperDecodable.swift
//  SpotImCore
//
//  Created by Refael Sommer on 29/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

struct OWFailableWrapperDecodable<T: Decodable>: Decodable {
    let wrappedValue: T?

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.wrappedValue = try? container.decode(T.self)
    }
}
