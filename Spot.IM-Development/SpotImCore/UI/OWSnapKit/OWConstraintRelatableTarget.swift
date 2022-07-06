//
//  OWConstraintRelatableTarget.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/02/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

protocol OWConstraintRelatableTarget {}

extension Int: OWConstraintRelatableTarget {}

extension UInt: OWConstraintRelatableTarget {}

extension Float: OWConstraintRelatableTarget {}

extension Double: OWConstraintRelatableTarget {}

extension CGFloat: OWConstraintRelatableTarget {}

extension CGSize: OWConstraintRelatableTarget {}

extension CGPoint: OWConstraintRelatableTarget {}

extension UIEdgeInsets: OWConstraintRelatableTarget {}

extension OWConstraintItem: OWConstraintRelatableTarget {}

extension UIView: OWConstraintRelatableTarget {}

extension OWConstraintLayoutGuide: OWConstraintRelatableTarget {}
