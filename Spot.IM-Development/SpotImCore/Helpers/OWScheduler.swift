//
//  OWScheduler.swift
//  SpotImCore
//
//  Created by Refael Sommer on 18/12/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

class OWScheduler {
    static func runOnMainThreadIfNeeded(completion: () -> Void) {
        if Thread.isMainThread {
            completion()
        } else {
            DispatchQueue.main.sync {
                completion()
            }
        }
    }
}
