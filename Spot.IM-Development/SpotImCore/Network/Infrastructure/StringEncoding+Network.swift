//
//  StringEncoding+Alamofire.swift
//  SpotImCore
//
//  Created by Alon Haiut on 20/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

extension String.Encoding {
    /// Creates an encoding from the IANA charset name.
    ///
    /// - Notes: These mappings match those [provided by CoreFoundation](https://opensource.apple.com/source/CF/CF-476.18/CFStringUtilities.c.auto.html)
    ///
    /// - Parameter name: IANA charset name.
    init?(ianaCharsetName name: String) {
        switch name.lowercased() {
        case "utf-8":
            self = .utf8
        case "iso-8859-1":
            self = .isoLatin1
        case "unicode-1-1", "iso-10646-ucs-2", "utf-16":
            self = .utf16
        case "utf-16be":
            self = .utf16BigEndian
        case "utf-16le":
            self = .utf16LittleEndian
        case "utf-32":
            self = .utf32
        case "utf-32be":
            self = .utf32BigEndian
        case "utf-32le":
            self = .utf32LittleEndian
        default:
            return nil
        }
    }
}
