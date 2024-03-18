//
//  UIApplication+Utils.swift
//  OpenWebSDK
//
//  Created by Revital Pisman on 01/02/2024.
//  Copyright © 2024 Spot.IM. All rights reserved.
//

import UIKit

extension UIApplication {
    var allowedOrientations: UIInterfaceOrientationMask {
        // Fetch the array of supported orientations from Info.plist
        guard let orientationsArray = Bundle.main.infoDictionary?["UISupportedInterfaceOrientations"] as? [String] else {
            return .all // Default to all if not specified
        }

        // Initialize an empty mask
        var allowedOrientations: UIInterfaceOrientationMask = []

        for orientationString in orientationsArray {
            switch orientationString {
            case "UIInterfaceOrientationPortrait":
                allowedOrientations.insert(.portrait)
            case "UIInterfaceOrientationPortraitUpsideDown":
                allowedOrientations.insert(.portraitUpsideDown)
            case "UIInterfaceOrientationLandscapeLeft":
                allowedOrientations.insert(.landscapeLeft)
            case "UIInterfaceOrientationLandscapeRight":
                allowedOrientations.insert(.landscapeRight)
            default:
                break // Ignore any unrecognized values
            }
        }

        return allowedOrientations
    }

    var isPortraitAllowed: Bool {
        return allowedOrientations.contains(.portrait) || allowedOrientations.contains(.portraitUpsideDown)
    }

    var isLandscapeAllowed: Bool {
        return allowedOrientations.contains(.landscapeLeft) || allowedOrientations.contains(.landscapeRight)
    }
}
