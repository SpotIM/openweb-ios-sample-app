//
//  OWConversationCountersCompletion.swift
//  SpotImCore
//
//  Created by Alon Haiut on 21/02/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public typealias OWConversationCountersCompletion = (Result<[OWPostId: OWConversationCounter], OWError>) -> Void
#else
typealias OWConversationCountersCompletion = (Result<[OWPostId: OWConversationCounter], OWError>) -> Void
#endif
