//
//  OWManager.swift
//  SpotImCore
//
//  Created by Alon Haiut on 07/03/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

class OWManager {
    
    // Singleton, will be public access once a new API will be ready.
    // Publishers and SDK consumers will basically interact with the manager / public encapsulation of it.
    static let shared = OWManager()
    
    private init() {
        
    }
}
