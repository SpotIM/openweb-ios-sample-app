//
//  OWAnimatableSectionModel.swift
//  SpotImCore
//
//  Created by Alon Haiut on 07/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

struct OWAnimatableSectionModel<Section: OWIdentifiableType, ItemType: OWIdentifiableType & Equatable> {
    var model: Section
    var items: [Item]

    init(model: Section, items: [ItemType]) {
        self.model = model
        self.items = items
    }
    
}

extension OWAnimatableSectionModel: OWAnimatableSectionModelType {
    typealias Item = ItemType
    typealias Identity = Section.Identity

    var identity: Section.Identity {
        return model.identity
    }

    init(original: OWAnimatableSectionModel, items: [Item]) {
        self.model = original.model
        self.items = items
    }
    
    var hashValue: Int {
        return self.model.identity.hashValue
    }
}


extension OWAnimatableSectionModel: CustomStringConvertible {

    var description: String {
        return "HashableSectionModel(model: \"\(self.model)\", items: \(items))"
    }

}

extension OWAnimatableSectionModel: Equatable where Section: Equatable {
    
    static func == (lhs: OWAnimatableSectionModel, rhs: OWAnimatableSectionModel) -> Bool {
        return lhs.model == rhs.model
            && lhs.items == rhs.items
    }
}
