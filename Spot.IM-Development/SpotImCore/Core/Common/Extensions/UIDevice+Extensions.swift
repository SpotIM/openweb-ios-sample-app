//
//  UIDevice+Extensions.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 02/10/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

internal extension UIDevice {

    static func modelIdentifier() -> String {
        if let simulatorModelIdentifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
            return simulatorModelIdentifier
        }
        var sysinfo = utsname()
        uname(&sysinfo) // ignore return value
        let data = Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN))
        if let deviceModel = String(bytes: data, encoding: .ascii) {
            return deviceModel.trimmingCharacters(in: .controlCharacters)
        } else {
            return "Unknown model"
        }
    }

}
