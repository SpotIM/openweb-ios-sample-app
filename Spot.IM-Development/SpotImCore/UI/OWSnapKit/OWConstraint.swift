//
//  OWConstraint.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/02/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit


class OWConstraint {
    struct Helpers {
        static let servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared
        static let loggerPrefix = "OpenWebSDKSnapKitLogger"
    }
    
    let sourceLocation: (String, UInt)
    
    private let label: String?
    private let from: OWConstraintItem
    private let to: OWConstraintItem
    private let relation: OWConstraintRelation
    private let multiplier: OWConstraintMultiplierTarget
    private var constant: OWConstraintConstantTarget {
        didSet {
            self.updateConstantAndPriorityIfNeeded()
        }
    }
    private var priority: OWConstraintPriorityTarget {
        didSet {
          self.updateConstantAndPriorityIfNeeded()
        }
    }
    var layoutConstraints: [OWLayoutConstraint]

    var isActive: Bool {
        set {
            if newValue {
                activate()
            }
            else {
                deactivate()
            }
        }
        
        get {
            for layoutConstraint in self.layoutConstraints {
                if layoutConstraint.isActive {
                    return true
                }
            }
            return false
        }
    }
    
    // MARK: Initialization
    init(from: OWConstraintItem,
                  to: OWConstraintItem,
                  relation: OWConstraintRelation,
                  sourceLocation: (String, UInt),
                  label: String?,
                  multiplier: OWConstraintMultiplierTarget,
                  constant: OWConstraintConstantTarget,
                  priority: OWConstraintPriorityTarget) {
        self.from = from
        self.to = to
        self.relation = relation
        self.sourceLocation = sourceLocation
        self.label = label
        self.multiplier = multiplier
        self.constant = constant
        self.priority = priority
        self.layoutConstraints = []

        // get attributes
        let layoutFromAttributes = self.from.attributes.layoutAttributes
        let layoutToAttributes = self.to.attributes.layoutAttributes

        // get layout from
        let layoutFrom = self.from.layoutConstraintItem!

        // get relation
        let layoutRelation = self.relation.layoutRelation

        for layoutFromAttribute in layoutFromAttributes {
            // get layout to attribute
            let layoutToAttribute: OWLayoutAttribute
                if layoutToAttributes.count > 0 {
                    if self.from.attributes == .edges && self.to.attributes == .margins {
                        switch layoutFromAttribute {
                        case .left:
                            layoutToAttribute = .leftMargin
                        case .right:
                            layoutToAttribute = .rightMargin
                        case .top:
                            layoutToAttribute = .topMargin
                        case .bottom:
                            layoutToAttribute = .bottomMargin
                        default:
                            fatalError()
                        }
                    } else if self.from.attributes == .margins && self.to.attributes == .edges {
                        switch layoutFromAttribute {
                        case .leftMargin:
                            layoutToAttribute = .left
                        case .rightMargin:
                            layoutToAttribute = .right
                        case .topMargin:
                            layoutToAttribute = .top
                        case .bottomMargin:
                            layoutToAttribute = .bottom
                        default:
                            fatalError()
                        }
                    } else if self.from.attributes == .directionalEdges && self.to.attributes == .directionalMargins {
                      switch layoutFromAttribute {
                      case .leading:
                        layoutToAttribute = .leadingMargin
                      case .trailing:
                        layoutToAttribute = .trailingMargin
                      case .top:
                        layoutToAttribute = .topMargin
                      case .bottom:
                        layoutToAttribute = .bottomMargin
                      default:
                        fatalError()
                      }
                    } else if self.from.attributes == .directionalMargins && self.to.attributes == .directionalEdges {
                      switch layoutFromAttribute {
                      case .leadingMargin:
                        layoutToAttribute = .leading
                      case .trailingMargin:
                        layoutToAttribute = .trailing
                      case .topMargin:
                        layoutToAttribute = .top
                      case .bottomMargin:
                        layoutToAttribute = .bottom
                      default:
                        fatalError()
                      }
                    } else if self.from.attributes == self.to.attributes {
                        layoutToAttribute = layoutFromAttribute
                    } else {
                        layoutToAttribute = layoutToAttributes[0]
                    }
                } else {
                    if self.to.target == nil && (layoutFromAttribute == .centerX || layoutFromAttribute == .centerY) {
                        layoutToAttribute = layoutFromAttribute == .centerX ? .left : .top
                    } else {
                        layoutToAttribute = layoutFromAttribute
                    }
                }

            // get layout constant
            let layoutConstant: CGFloat = self.constant.constraintConstantTargetValueFor(layoutAttribute: layoutToAttribute)

            // get layout to
            var layoutTo: AnyObject? = self.to.target

            // use superview if possible
            if layoutTo == nil && layoutToAttribute != .width && layoutToAttribute != .height {
                layoutTo = layoutFrom.superview
            }

            // create layout constraint
            let layoutConstraint = OWLayoutConstraint(
                item: layoutFrom,
                attribute: layoutFromAttribute,
                relatedBy: layoutRelation,
                toItem: layoutTo,
                attribute: layoutToAttribute,
                multiplier: self.multiplier.constraintMultiplierTargetValue,
                constant: layoutConstant
            )

            // set label
            layoutConstraint.label = self.label

            // set priority
            layoutConstraint.priority = OWLayoutPriority(rawValue: self.priority.constraintPriorityTargetValue)

            // set constraint
            layoutConstraint.constraint = self

            // append
            self.layoutConstraints.append(layoutConstraint)
        }
    }

    func activate() {
        self.activateIfNeeded()
    }

    func deactivate() {
        self.deactivateIfNeeded()
    }

    @discardableResult
    func update(offset: OWConstraintOffsetTarget) -> OWConstraint {
        self.constant = offset.constraintOffsetTargetValue
        return self
    }

    @discardableResult
    func update(inset: OWConstraintInsetTarget) -> OWConstraint {
        self.constant = inset.constraintInsetTargetValue
        return self
    }

    @discardableResult
    func update(priority: OWConstraintPriorityTarget) -> OWConstraint {
        self.priority = priority.constraintPriorityTargetValue
        return self
    }

    @discardableResult
    func update(priority: OWConstraintPriority) -> OWConstraint {
        self.priority = priority.value
        return self
    }

    private func updateConstantAndPriorityIfNeeded() {
        for layoutConstraint in self.layoutConstraints {
            let attribute = (layoutConstraint.secondAttribute == .notAnAttribute) ? layoutConstraint.firstAttribute : layoutConstraint.secondAttribute
            layoutConstraint.constant = self.constant.constraintConstantTargetValueFor(layoutAttribute: attribute)

            let requiredPriority = OWConstraintPriority.required.value
            if (layoutConstraint.priority.rawValue < requiredPriority), (self.priority.constraintPriorityTargetValue != requiredPriority) {
                layoutConstraint.priority = OWLayoutPriority(rawValue: self.priority.constraintPriorityTargetValue)
            }
        }
    }

    func activateIfNeeded(updatingExisting: Bool = false) {
        guard let item = self.from.layoutConstraintItem else {
            Helpers.servicesProvider.logger().log(level: .medium, "WARNING: OWSnapKit failed to get from item from constraint. Activate will be a no-op.", prefix: Helpers.loggerPrefix)
            return
        }
        let layoutConstraints = self.layoutConstraints

        if updatingExisting {
            var existingLayoutConstraints: [OWLayoutConstraint] = []
            for constraint in item.constraints {
                existingLayoutConstraints += constraint.layoutConstraints
            }

            for layoutConstraint in layoutConstraints {
                let existingLayoutConstraint = existingLayoutConstraints.first { $0 == layoutConstraint }
                guard let updateLayoutConstraint = existingLayoutConstraint else {
                    fatalError("OWSnapKit - Updated constraint could not find existing matching constraint to update: \(layoutConstraint)")
                }

                let updateLayoutAttribute = (updateLayoutConstraint.secondAttribute == .notAnAttribute) ? updateLayoutConstraint.firstAttribute : updateLayoutConstraint.secondAttribute
                updateLayoutConstraint.constant = self.constant.constraintConstantTargetValueFor(layoutAttribute: updateLayoutAttribute)
            }
        } else {
            NSLayoutConstraint.activate(layoutConstraints)
            item.add(constraints: [self])
        }
    }

    func deactivateIfNeeded() {
        guard let item = self.from.layoutConstraintItem else {
            Helpers.servicesProvider.logger().log(level: .medium, "WARNING: OWSnapKit failed to get from item from constraint. Deactivate will be a no-op.", prefix: Helpers.loggerPrefix)
            return
        }
        let layoutConstraints = self.layoutConstraints
        NSLayoutConstraint.deactivate(layoutConstraints)
        item.remove(constraints: [self])
    }
}

