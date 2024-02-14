//
//  OWConversationCountersCompletion.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 21/02/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation

public typealias OWConversationCountersCompletion = (Result<[OWPostId: OWConversationCounter], OWError>) -> Void
