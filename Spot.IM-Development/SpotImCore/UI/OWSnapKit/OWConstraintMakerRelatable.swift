//
//  OWConstraintMakerRelatable.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/02/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

class OWConstraintMakerRelatable {

    let description: OWConstraintDescription

    init(_ description: OWConstraintDescription) {
        self.description = description
    }

    func relatedTo(_ other: OWConstraintRelatableTarget, relation: OWConstraintRelation, file: String, line: UInt) -> OWConstraintMakerEditable {
        let related: OWConstraintItem
        let constant: OWConstraintConstantTarget

        if let other = other as? OWConstraintItem {
            guard other.attributes == OWConstraintAttributes.none ||
                  other.attributes.layoutAttributes.count <= 1 ||
                  other.attributes.layoutAttributes == self.description.attributes.layoutAttributes ||
                  other.attributes == .edges && self.description.attributes == .margins ||
                  other.attributes == .margins && self.description.attributes == .edges ||
                  other.attributes == .directionalEdges && self.description.attributes == .directionalMargins ||
                  other.attributes == .directionalMargins && self.description.attributes == .directionalEdges else {
                fatalError("OWSnapKit - Cannot constraint to multiple non identical attributes. (\(file), \(line))")
            }

            related = other
            constant = 0.0
        } else if let other = other as? UIView {
            related = OWConstraintItem(target: other, attributes: OWConstraintAttributes.none)
            constant = 0.0
        } else if let other = other as? OWConstraintConstantTarget {
            related = OWConstraintItem(target: nil, attributes: OWConstraintAttributes.none)
            constant = other
        } else if let other = other as? OWConstraintLayoutGuide {
            related = OWConstraintItem(target: other, attributes: OWConstraintAttributes.none)
            constant = 0.0
        } else {
            fatalError("OWSnapKit - Invalid constraint. (\(file), \(line))")
        }

        let editable = OWConstraintMakerEditable(self.description)
        editable.description.sourceLocation = (file, line)
        editable.description.relation = relation
        editable.description.related = related
        editable.description.constant = constant
        return editable
    }

    @discardableResult
    func equalTo(_ other: OWConstraintRelatableTarget, _ file: String = #file, _ line: UInt = #line) -> OWConstraintMakerEditable {
        return self.relatedTo(other, relation: .equal, file: file, line: line)
    }

    @discardableResult
    func equalToSuperviewSafeArea(_ file: String = #file, _ line: UInt = #line) -> OWConstraintMakerEditable {
        guard let other = self.description.item.superview else {
            fatalError("OWSnapKit - Expected superview but found nil when attempting make constraint `equalToSuperviewSafeArea`.")
        }
        return self.relatedTo(other.safeAreaLayoutGuide, relation: .equal, file: file, line: line)
    }

    @discardableResult
    func equalToSuperview(_ file: String = #file, _ line: UInt = #line) -> OWConstraintMakerEditable {
        guard let other = self.description.item.superview else {
            fatalError("OWSnapKit - Expected superview but found nil when attempting make constraint `equalToSuperview`.")
        }
        return self.relatedTo(other, relation: .equal, file: file, line: line)
    }

    @discardableResult
    func lessThanOrEqualTo(_ other: OWConstraintRelatableTarget, _ file: String = #file, _ line: UInt = #line) -> OWConstraintMakerEditable {
        return self.relatedTo(other, relation: .lessThanOrEqual, file: file, line: line)
    }

    @discardableResult
    func lessThanOrEqualToSuperview(_ file: String = #file, _ line: UInt = #line) -> OWConstraintMakerEditable {
        guard let other = self.description.item.superview else {
            fatalError("OWSnapKit - Expected superview but found nil when attempting make constraint `lessThanOrEqualToSuperview`.")
        }
        return self.relatedTo(other, relation: .lessThanOrEqual, file: file, line: line)
    }

    @discardableResult
    func greaterThanOrEqualTo(_ other: OWConstraintRelatableTarget, _ file: String = #file, line: UInt = #line) -> OWConstraintMakerEditable {
        return self.relatedTo(other, relation: .greaterThanOrEqual, file: file, line: line)
    }

    @discardableResult
    func greaterThanOrEqualToSuperview(_ file: String = #file, line: UInt = #line) -> OWConstraintMakerEditable {
        guard let other = self.description.item.superview else {
            fatalError("OWSnapKit - Expected superview but found nil when attempting make constraint `greaterThanOrEqualToSuperview`.")
        }
        return self.relatedTo(other, relation: .greaterThanOrEqual, file: file, line: line)
    }
}
