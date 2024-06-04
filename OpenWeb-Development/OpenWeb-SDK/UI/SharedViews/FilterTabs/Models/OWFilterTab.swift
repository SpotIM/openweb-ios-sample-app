//
//  OWFilterTab.swift
//  OpenWebSDK
//
//  Created by Refael Sommer on 02/06/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation

struct OWFilterTab: Codable {
    let id: String
    let count: Int
    let label: String
    let sortOptions: [String]?
}
