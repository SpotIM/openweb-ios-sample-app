//
//  OWConstraintMakerFinalizable.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/02/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

class OWConstraintMakerFinalizable {

    let description: OWConstraintDescription

    init(_ description: OWConstraintDescription) {
        self.description = description
    }

    @discardableResult
    func labeled(_ label: String) -> OWConstraintMakerFinalizable {
        self.description.label = label
        return self
    }

    var constraint: OWConstraint {
        return self.description.constraint!
    }
}
