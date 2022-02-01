//
//  SPDefaultDecoder.swift
//  Spot.IM-Core
//
//  Created by Eugene on 8/27/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

let defaultDecoder: JSONDecoder = {
    let decoder = JSONDecoder().applyingDefaultParameters()
    return decoder
}()

extension JSONDecoder {
    
    /// Setup decoder with all needed default parameters
    func applyingDefaultParameters() -> Self {
        self.keyDecodingStrategy = .convertFromSnakeCase
        
        return self
    }
    
}
