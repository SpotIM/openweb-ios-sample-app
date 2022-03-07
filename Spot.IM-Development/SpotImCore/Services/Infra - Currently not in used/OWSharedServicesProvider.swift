//
//  OWSharedServicesProvider.swift
//  SpotImCore
//
//  Created by Alon Haiut on 07/03/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

protocol OWSharedServicesProviding {
    
}

class OWSharedServicesProvider: OWSharedServicesProviding {
    
    // Singleton
    static let shared: OWSharedServicesProviding = OWSharedServicesProvider()
    
    private init() {
        
    }
}
