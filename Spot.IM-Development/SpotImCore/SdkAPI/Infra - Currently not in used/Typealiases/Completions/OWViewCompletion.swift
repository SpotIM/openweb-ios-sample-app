//
//  OWViewCompletion.swift
//  SpotImCore
//
//  Created by Alon Haiut on 07/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

#if NEW_API
public typealias OWViewCompletion = (Result<UIView, OWError>) -> Void
#else
typealias OWViewCompletion = (Result<UIView, OWError>) -> Void
#endif
