//
//  OWViewActionsCallbacks.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public typealias OWViewActionsCallbacks = (OWViewActionCallbackType, OWViewSourceType, String) -> Void
#else
typealias OWViewActionsCallbacks = (OWViewActionCallbackType, OWViewSourceType, String) -> Void
#endif
