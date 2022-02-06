//
//  OWConstraintMultiplierTarget.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/02/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

protocol OWConstraintMultiplierTarget {
    var constraintMultiplierTargetValue: CGFloat { get }
}

extension Int: OWConstraintMultiplierTarget {
    var constraintMultiplierTargetValue: CGFloat {
        return CGFloat(self)
    }
}

extension UInt: OWConstraintMultiplierTarget {
    var constraintMultiplierTargetValue: CGFloat {
        return CGFloat(self)
    }
}

extension Float: OWConstraintMultiplierTarget {
    var constraintMultiplierTargetValue: CGFloat {
        return CGFloat(self)
    }
}

extension Double: OWConstraintMultiplierTarget {
    var constraintMultiplierTargetValue: CGFloat {
        return CGFloat(self)
    }
}

extension CGFloat: OWConstraintMultiplierTarget {
    var constraintMultiplierTargetValue: CGFloat {
        return self
    }
}
