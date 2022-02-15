//
//  OWConstraintMaker.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/02/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

class OWConstraintMaker {
    
    var left: OWConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.left)
    }
    
    var top: OWConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.top)
    }
    
    var bottom: OWConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.bottom)
    }
    
    var right: OWConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.right)
    }
    
    var leading: OWConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.leading)
    }
    
    var trailing: OWConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.trailing)
    }
    
    var width: OWConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.width)
    }
    
    var height: OWConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.height)
    }
    
    var centerX: OWConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.centerX)
    }
    
    var centerY: OWConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.centerY)
    }
    
    var lastBaseline: OWConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.lastBaseline)
    }
    
    var firstBaseline: OWConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.firstBaseline)
    }
    
    var leftMargin: OWConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.leftMargin)
    }
    
    var rightMargin: OWConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.rightMargin)
    }
    
    var topMargin: OWConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.topMargin)
    }
    
    var bottomMargin: OWConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.bottomMargin)
    }
    
    var leadingMargin: OWConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.leadingMargin)
    }
    
    var trailingMargin: OWConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.trailingMargin)
    }
    
    var centerXWithinMargins: OWConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.centerXWithinMargins)
    }
    
    var centerYWithinMargins: OWConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.centerYWithinMargins)
    }
    
    var edges: OWConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.edges)
    }
    var horizontalEdges: OWConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.horizontalEdges)
    }
    var verticalEdges: OWConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.verticalEdges)
    }
    var directionalEdges: OWConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.directionalEdges)
    }
    var directionalHorizontalEdges: OWConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.directionalHorizontalEdges)
    }
    var directionalVerticalEdges: OWConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.directionalVerticalEdges)
    }
    var size: OWConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.size)
    }
    var center: OWConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.center)
    }
    
    var margins: OWConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.margins)
    }
    
    var directionalMargins: OWConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.directionalMargins)
    }

    var centerWithinMargins: OWConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.centerWithinMargins)
    }
    
    let item: OWLayoutConstraintItem
    private var descriptions = [OWConstraintDescription]()
    
    private init(item: OWLayoutConstraintItem) {
        self.item = item
        self.item.prepare()
    }
    
    private func makeExtendableWithAttributes(_ attributes: OWConstraintAttributes) -> OWConstraintMakerExtendable {
        let description = OWConstraintDescription(item: self.item, attributes: attributes)
        self.descriptions.append(description)
        return OWConstraintMakerExtendable(description)
    }
    
    static func prepareConstraints(item: OWLayoutConstraintItem, closure: (_ make: OWConstraintMaker) -> Void) -> [OWConstraint] {
        let maker = OWConstraintMaker(item: item)
        closure(maker)
        var constraints: [OWConstraint] = []
        for description in maker.descriptions {
            guard let constraint = description.constraint else {
                continue
            }
            constraints.append(constraint)
        }
        return constraints
    }
    
    static func makeConstraints(item: OWLayoutConstraintItem, closure: (_ make: OWConstraintMaker) -> Void) {
        let constraints = prepareConstraints(item: item, closure: closure)
        for constraint in constraints {
            constraint.activateIfNeeded(updatingExisting: false)
        }
    }
    
    static func remakeConstraints(item: OWLayoutConstraintItem, closure: (_ make: OWConstraintMaker) -> Void) {
        self.removeConstraints(item: item)
        self.makeConstraints(item: item, closure: closure)
    }
    
    static func updateConstraints(item: OWLayoutConstraintItem, closure: (_ make: OWConstraintMaker) -> Void) {
        guard item.constraints.count > 0 else {
            self.makeConstraints(item: item, closure: closure)
            return
        }
        
        let constraints = prepareConstraints(item: item, closure: closure)
        for constraint in constraints {
            constraint.activateIfNeeded(updatingExisting: true)
        }
    }
    
    static func removeConstraints(item: OWLayoutConstraintItem) {
        let constraints = item.constraints
        for constraint in constraints {
            constraint.deactivateIfNeeded()
        }
    }
}
