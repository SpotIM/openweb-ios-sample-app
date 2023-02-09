//
//  OWSortingCustomizer.swift
//  SpotImCore
//
//  Created by Alon Haiut on 08/11/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

protocol OWSortingCustomizationsInternal {
    func customizedTitle(forOption sortOption: OWSortOption) -> OWCustomizedSortTitle
}

class OWSortingCustomizer: OWSortingCustomizations, OWSortingCustomizationsInternal {
    
    fileprivate var customizationTitleMapper: [OWSortOption: String] = [:]
    
    var initialOption: OWSortOption = .default
    
    func setTitle(_ title: String, forOption sortOption: OWSortOption) {
        customizationTitleMapper[sortOption] = title
    }
    
    func customizedTitle(forOption sortOption: OWSortOption) -> OWCustomizedSortTitle {
        guard let title = customizationTitleMapper[sortOption] else {
            return .none
        }
        
        return .customized(title: title)
    }
}
