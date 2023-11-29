//
//  ThirdPartySSOAuthentication.swift
//  Spot-IM.Development
//
//  Created by  Nogah Melamed on 29/11/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import SpotImCore

struct ThirdPartySSOAuthentication {
    let displayName: String
    let spotId: String
    let token: String
    let provider: OWSSOProvider
}

extension ThirdPartySSOAuthentication {
    static let mockModels = Self.createMockModels()

    static func createMockModels() -> [ThirdPartySSOAuthentication] {
    #if PUBLIC_DEMO_APP
        return []
    #else
        return [
            // swiftlint:disable line_length
            ThirdPartySSOAuthentication(displayName: "Fox",
                                     spotId: "sp_ANQXRpqH",
                                     token: "eyJhbGciOiJSUzI1NiIsImtpZCI6Ijg5REEwNkVEMjAxOCIsInR5cCI6IkpXVCJ9.eyJwaWQiOiJ1cy1lYXN0LTE6NDAxYjMyMjgtZWE2NC00YTU2LThmYzEtZTgyYzkxY2FhZDJmIiwidWlkIjoiTkRBeFlqTXlNamd0WldFMk5DMDBZVFUyTFRobVl6RXRaVGd5WXpreFkyRmhaREptIiwic2lkIjoiYjU2ZWFhNjUtZWQzZC00NGYxLThmMTItZDU1ZjljOGE1ODIxIiwic2RjIjoidXMtZWFzdC0xIiwiYXR5cGUiOiJpZGVudGl0eSIsImR0eXBlIjoid2ViIiwidXR5cGUiOiJlbWFpbCIsImRpZCI6IiIsIm12cGRpZCI6IiIsInZlciI6MiwiZW50Ijp7fSwiZXhwIjoxNzAwNTI5NzE0LCJqdGkiOiI4YTAwNTQ0Ni1iODllLTQ0ZjUtYmIzOC1jOGJhZDhiNzZmYmYiLCJpYXQiOjE2NTMyMjU3MTR9.YSsurteEDw6ZaPvO5rcC_ld2aW6l486gRajXsjTQjLsDqc2wREqi-AfnjTWI6qMc7Jkp08x-gHL3HxmgnD6xisHsskJLLZC_Sa7O5Aky1PydbN6ixmu1tVe-ZwA1TxfTh7B4B2MyjaTs9az56KZ1Uw5Q4Xr0Wl57eyZCZVdOotw7F1cTlOAPb7fYuApN0lvRioURDlxjeKStHL4BLfpypydW8YjhMtlbYJ_3QQy7bXY5uWPfBV5Cv7CKaE-4b0m923Q5KFV9_czBm8QjtLiNEjZCfcDVfnn4lpFBQCjXg0piNq7Xl0bOCODAJepLQGfyY63t2xbILiwy8EQh_qLLOw",
                                        provider: .foxid)
            ]
            // swiftlint:enable line_length
    #endif
    }
}
