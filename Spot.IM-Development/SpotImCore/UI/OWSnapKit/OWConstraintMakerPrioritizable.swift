//
//  OWConstraintMakerPrioritizable.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/02/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

class OWConstraintMakerPrioritizable: OWConstraintMakerFinalizable {
    
    @discardableResult
    func priority(_ amount: OWConstraintPriority) -> OWConstraintMakerFinalizable {
        self.description.priority = amount.value
        return self
    }
    
    @discardableResult
    func priority(_ amount: OWConstraintPriorityTarget) -> OWConstraintMakerFinalizable {
        self.description.priority = amount
        return self
    }
}
