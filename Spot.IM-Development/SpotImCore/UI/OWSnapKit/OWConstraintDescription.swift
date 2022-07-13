//
//  OWConstraintDescription.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/02/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit


class OWConstraintDescription {
    let item: OWLayoutConstraintItem
    var attributes: OWConstraintAttributes
    var relation: OWConstraintRelation? = nil
    var sourceLocation: (String, UInt)? = nil
    var label: String? = nil
    var related: OWConstraintItem? = nil
    var multiplier: OWConstraintMultiplierTarget = 1.0
    var constant: OWConstraintConstantTarget = 0.0
    var priority: OWConstraintPriorityTarget = 1000.0
    lazy var constraint: OWConstraint? = {
        guard let relation = self.relation,
              let related = self.related,
              let sourceLocation = self.sourceLocation else {
            return nil
        }
        let from = OWConstraintItem(target: self.item, attributes: self.attributes)
        
        return OWConstraint(
            from: from,
            to: related,
            relation: relation,
            sourceLocation: sourceLocation,
            label: self.label,
            multiplier: self.multiplier,
            constant: self.constant,
            priority: self.priority
        )
    }()
    
    // MARK: Initialization
    init(item: OWLayoutConstraintItem, attributes: OWConstraintAttributes) {
        self.item = item
        self.attributes = attributes
    }
}

