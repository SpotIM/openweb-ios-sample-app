//
//  OWSortingCustomizations.swift
//  SpotImCore
//
//  Created by Alon Haiut on 09/02/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

public protocol OWSortingCustomizations {
    func setTitle(_ title: String, forOption sortOption: OWSortOption)
    var initialOption: OWInitialSortStrategy { get set }
}
