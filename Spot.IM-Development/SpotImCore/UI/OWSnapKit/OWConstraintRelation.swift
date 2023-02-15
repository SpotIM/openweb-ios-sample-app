//
//  OWConstraintRelation.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/02/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

enum OWConstraintRelation: Int {
    case equal = 1
    case lessThanOrEqual
    case greaterThanOrEqual

    var layoutRelation: OWLayoutRelation {
        get {
            switch(self) {
            case .equal:
                return .equal
            case .lessThanOrEqual:
                return .lessThanOrEqual
            case .greaterThanOrEqual:
                return .greaterThanOrEqual
            }
        }
    }
}
