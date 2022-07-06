//
//  OWConstraintMakerEditable.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/02/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

class OWConstraintMakerEditable: OWConstraintMakerPrioritizable {

    @discardableResult
    func multipliedBy(_ amount: OWConstraintMultiplierTarget) -> OWConstraintMakerEditable {
        self.description.multiplier = amount
        return self
    }
    
    @discardableResult
    func dividedBy(_ amount: OWConstraintMultiplierTarget) -> OWConstraintMakerEditable {
        return self.multipliedBy(1.0 / amount.constraintMultiplierTargetValue)
    }
    
    @discardableResult
    func offset(_ amount: OWConstraintOffsetTarget) -> OWConstraintMakerEditable {
        self.description.constant = amount.constraintOffsetTargetValue
        return self
    }
    
    @discardableResult
    func inset(_ amount: OWConstraintInsetTarget) -> OWConstraintMakerEditable {
        self.description.constant = amount.constraintInsetTargetValue
        return self
    }
}
