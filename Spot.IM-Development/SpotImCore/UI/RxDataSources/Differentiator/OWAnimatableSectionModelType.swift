//
//  OWAnimatableSectionModelType.swift
//  SpotImCore
//
//  Created by Alon Haiut on 07/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

protocol OWAnimatableSectionModelType: OWSectionModelType, OWIdentifiableType where Item: OWIdentifiableType, Item: Equatable {}
