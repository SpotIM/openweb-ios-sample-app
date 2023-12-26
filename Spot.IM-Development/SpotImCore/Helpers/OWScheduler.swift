//
//  OWScheduler.swift
//  SpotImCore
//
//  Created by Refael Sommer on 18/12/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

class OWScheduler {
    static func runOnMainThreadIfNeeded(block: @escaping () -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.async {
                block()
            }
        }
    }
}
