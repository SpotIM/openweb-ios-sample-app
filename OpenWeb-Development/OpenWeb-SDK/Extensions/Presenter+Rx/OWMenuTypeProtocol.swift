//
//  OWMenuTypeProtocol.swift
//  SpotImCore
//
//  Created by Alon Shprung on 04/06/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation

protocol OWMenuTypeProtocol {
    var rawValue: String { get }
    var identifier: String { get }
}

extension OWMenuTypeProtocol {
    var identifier: String {
        return rawValue
    }
}
