//
//  OWFilterTabObject.swift
//  OpenWebSDK
//
//  Created by Refael Sommer on 03/06/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation

class OWFilterTabObject {
    let id: String
    let count: Int
    let name: String
    let sortOptions: [String]?
    var selected: Bool = false

    init(id: String, count: Int, name: String, sortOptions: [String]?) {
        self.id = id
        self.count = count
        self.name = name
        self.sortOptions = sortOptions
    }

    static var defaultTabId: OWFilterTabId {
        // This will be returned as a default filter tab id
        return "all"
    }

    static var networkExcludeIds: [OWFilterTabId] {
        // These ids will not be sent in conversation/read API
        return ["all", "all_newest", "all_oldest"]
    }
}
