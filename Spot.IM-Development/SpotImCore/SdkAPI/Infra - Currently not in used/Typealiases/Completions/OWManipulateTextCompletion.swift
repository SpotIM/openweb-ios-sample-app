//
//  OWManipulateTextCompletion.swift
//  SpotImCore
//
//  Created by Alon Haiut on 13/07/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public typealias OWManipulateTextCompletion = (Result<String, OWError>) -> String
#else
typealias OWManipulateTextCompletion = (Result<String, OWError>) -> String
#endif
