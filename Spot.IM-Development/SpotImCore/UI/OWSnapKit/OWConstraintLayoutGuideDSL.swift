//
//  OWConstraintLayoutGuideDSL.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/02/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

struct OWConstraintLayoutGuideDSL: OWConstraintAttributesDSL {

    @discardableResult
    func prepareConstraints(_ closure: (_ make: OWConstraintMaker) -> Void) -> [OWConstraint] {
        return OWConstraintMaker.prepareConstraints(item: self.guide, closure: closure)
    }

    func makeConstraints(_ closure: (_ make: OWConstraintMaker) -> Void) {
        OWConstraintMaker.makeConstraints(item: self.guide, closure: closure)
    }

    func remakeConstraints(_ closure: (_ make: OWConstraintMaker) -> Void) {
        OWConstraintMaker.remakeConstraints(item: self.guide, closure: closure)
    }

    func updateConstraints(_ closure: (_ make: OWConstraintMaker) -> Void) {
        OWConstraintMaker.updateConstraints(item: self.guide, closure: closure)
    }

    func removeConstraints() {
        OWConstraintMaker.removeConstraints(item: self.guide)
    }

    var target: AnyObject? {
        return self.guide
    }

    private let guide: OWConstraintLayoutGuide

    init(guide: OWConstraintLayoutGuide) {
        self.guide = guide

    }
}
