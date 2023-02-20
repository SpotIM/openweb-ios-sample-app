//
//  OWPostId+EncodeDecode.swift
//  SpotImCore
//
//  Created by Alon Haiut on 18/04/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

extension OWPostId {
    // Encoded
    var encoded: String {
        return self.replacingOccurrences(of: "urn:uri:base64:", with: "urn$3Auri$3Abase64$3A")
            .replacingOccurrences(of: ",", with: ";")
            .replacingOccurrences(of: "_", with: "$")
            .replacingOccurrences(of: ":", with: "~")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "/", with: "$2F")
    }

    // Decoded
    // We cannot decode back an original space, that's a limitation we cannot solve at this point of the product
    var decoded: String {
        return self.replacingOccurrences(of: "urn$3Auri$3Abase64$3A", with: "urn:uri:base64:")
            .replacingOccurrences(of: ";", with: ",")
            .replacingOccurrences(of: "$2F", with: "/")
            .replacingOccurrences(of: "$", with: "_")
            .replacingOccurrences(of: "~", with: ":")
    }
}
