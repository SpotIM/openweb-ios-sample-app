//
//  OWViewDynamicSizeCompletion.swift
//  SpotImCore
//
//  Created by Alon Haiut on 07/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public typealias OWViewDynamicSizeCompletion = (Result<OWViewDynamicSizeOption, OWError>) -> Void
#else
typealias OWViewDynamicSizeCompletion = (Result<OWViewDynamicSizeOption, OWError>) -> Void
#endif
