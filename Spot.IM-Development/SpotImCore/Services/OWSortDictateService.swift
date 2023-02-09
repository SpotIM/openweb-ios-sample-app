//
//  OWSortDictateService.swift
//  SpotImCore
//
//  Created by Alon Haiut on 09/02/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWSortDictateServicing {
    func sortOption(perPostId postId: OWPostId) -> Observable<OWSortOption>
    func sortTranslation(perOption option: OWSortOption) -> String
    func update(sortOption: OWSortOption, perPostId postId: OWPostId)
}

class OWSortDictateService: OWSortDictateServicing {
    func sortOption(perPostId postId: OWPostId) -> Observable<OWSortOption> {
        return .empty()
    }
    
    func sortTranslation(perOption option: OWSortOption) -> String {
        return ""
    }
    
    func update(sortOption: OWSortOption, perPostId postId: OWPostId) {
        
    }
}
