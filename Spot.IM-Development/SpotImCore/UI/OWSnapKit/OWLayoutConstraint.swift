//
//  OWLayoutConstraint.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/02/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

class OWLayoutConstraint: NSLayoutConstraint {
    var label: String? {
        get {
            return self.identifier
        }
        set {
            self.identifier = newValue
        }
    }

    weak var constraint: OWConstraint? = nil
}

func == (lhs: OWLayoutConstraint, rhs: OWLayoutConstraint) -> Bool {
    // If firstItem or secondItem on either constraint has a dangling pointer
    // this comparison can cause a crash. The solution for this is to ensure
    // your layout code hold strong references to things like Views, LayoutGuides
    // and LayoutAnchors as SnapKit will not keep strong references to any of these.
    guard lhs.firstAttribute == rhs.firstAttribute &&
          lhs.secondAttribute == rhs.secondAttribute &&
          lhs.relation == rhs.relation &&
          lhs.priority == rhs.priority &&
          lhs.multiplier == rhs.multiplier &&
          lhs.secondItem === rhs.secondItem &&
          lhs.firstItem === rhs.firstItem else {
        return false
    }
    return true
}
