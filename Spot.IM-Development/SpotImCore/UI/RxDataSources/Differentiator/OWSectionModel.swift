//
//  OWSectionModel.swift
//  SpotImCore
//
//  Created by Alon Haiut on 07/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

struct OWSectionModel<Section, ItemType> {
    var model: Section
    var items: [Item]

    init(model: Section, items: [Item]) {
        self.model = model
        self.items = items
    }
}

extension OWSectionModel: OWSectionModelType {
    typealias Identity = Section
    typealias Item = ItemType
    
    var identity: Section {
        return model
    }
}

extension OWSectionModel: CustomStringConvertible {

    var description: String {
        return "\(self.model) > \(items)"
    }
}

extension OWSectionModel {
    init(original: OWSectionModel<Section, Item>, items: [Item]) {
        self.model = original.model
        self.items = items
    }
}

extension OWSectionModel: Equatable where Section: Equatable, ItemType: Equatable {
    static func == (lhs: OWSectionModel, rhs: OWSectionModel) -> Bool {
        return lhs.model == rhs.model
            && lhs.items == rhs.items
    }
}
