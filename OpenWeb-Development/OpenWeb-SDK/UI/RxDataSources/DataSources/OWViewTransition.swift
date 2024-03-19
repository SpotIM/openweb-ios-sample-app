//
//  OWViewTransition.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 07/07/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation

// Transition between two view states
enum OWViewTransition {
    // animated transition
    case animated
    // refresh view without animations
    case reload
}
