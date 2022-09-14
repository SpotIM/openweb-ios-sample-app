//
//  OWDefaultCompletion.swift
//  SpotImCore
//
//  Created by Alon Haiut on 05/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public typealias OWDefaultCompletion = (Result<Void, OWError>) -> Void
#else
typealias OWDefaultCompletion = (Result<Void, OWError>) -> Void
#endif
