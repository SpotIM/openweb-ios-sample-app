//
//  OWConstraintPriorityTarget.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/02/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

protocol OWConstraintPriorityTarget {
    var constraintPriorityTargetValue: Float { get }
}

extension Int: OWConstraintPriorityTarget {
    var constraintPriorityTargetValue: Float {
        return Float(self)
    }
}

extension UInt: OWConstraintPriorityTarget {
    var constraintPriorityTargetValue: Float {
        return Float(self)
    }
}

extension Float: OWConstraintPriorityTarget {
    var constraintPriorityTargetValue: Float {
        return self
    }
}

extension Double: OWConstraintPriorityTarget {
    var constraintPriorityTargetValue: Float {
        return Float(self)
    }
}

extension CGFloat: OWConstraintPriorityTarget {
    var constraintPriorityTargetValue: Float {
        return Float(self)
    }
}

extension OWLayoutPriority: OWConstraintPriorityTarget {
    var constraintPriorityTargetValue: Float {
        return self.rawValue
    }
}
