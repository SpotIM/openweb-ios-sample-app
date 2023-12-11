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
                                     token: "eyJhbGciOiJSUzI1NiIsImtpZCI6IjZlZGU5YmE4LTQ5YWMtNGI4MS05YTQ5LTU3OTA5NzNjNTRkZSIsInR5cCI6IkpXVCJ9.eyJhdHlwZSI6ImlkZW50aXR5IiwiYXVkIjpbXSwiY2xpZW50X2lkIjoiZWYwOGRhZTItNjJhZS00NjczLWI5ZWYtNGI1NmZhMmQ4MWM0IiwiZGlkIjoiMWFlMzY5YmItZjM0MS00NDQ5LTllZGMtZTRiMWMxMWM3ZDQyIiwiZHR5cGUiOiJ3ZWIiLCJleHAiOjE3MDIzODI1NzUsImlhdCI6MTcwMjI5NjE3NCwiaXNzIjoiaHR0cHM6Ly9hcGkzLmZveC5jb20vdjIuMCIsImp0aSI6ImI5NGI1Yzg5LThiYmEtNDUwYS1hNjc1LTI4MTgwMjRkNDc2NSIsIm5iZiI6MTcwMjI5NjE3NCwicGlkIjoidXMtZWFzdC0xOmQ4MTAwYjBkLWY1Y2EtNDJiMS05Y2I2LTQ3MjJiYTJmMTg3MyIsInNjcCI6WyJvcGVuaWQiLCJvZmZsaW5lIl0sInNkYyI6InVzLWVhc3QtMSIsInNpZCI6IjQ1OTQwZjU1LTE0MTgtNDFkOS1iYmI3LThjZWI4NGFjMzAxMyIsInN1YiI6Im9sZWtzYW5kci50QG9wZW53ZWIuY29tIiwidWlkIjoiWkRneE1EQmlNR1F0WmpWallTMDBNbUl4TFRsallqWXRORGN5TW1KaE1tWXhPRGN6IiwidXR5cGUiOiJlbWFpbCIsInZlciI6Mn0.GslH4MvB4vwE4nm2Im_XIFykL2O_TRyo0F18rZTWsD4jOjkhL13ASFh-4ZMpkGgB52m5CuBHiYJKby-x5-0GaFS3Zmp5XsXKrBkFU3ED2TvK_UnDQIML7BRw2YeK7iWARRMZEjC35s3wDlL324NsZy5y9el3fGkvHyHTOulIm-CQjVhTqg9fwwZRKjyff4nYSrCR6utEjk7uAwba6J0cFM6ky3OFRDbbHla1cewpQGocoem8uvpO5wpr30LQH8T0wrtDg-U3x-Ux9IPy8sYfeYAE0b1feI2Rs_qIXrvTYppzEcN-yFHu3tZt0hP1gVSic-O03L-wAmPHyEhKsl4Rn5Egaw8LmiNYZnTmaoud3RGoS5EIL3RSYjTWmV7ae_tF55RcmCRmQL_fk2rgd7Jcgj4X3tN7GZmQmzkDFbvMbBYpzpWeFvp6VIwUKdnqE6lb_1wsPmkFV_9DJ4UKnmnXVfKqpFNJpB9emsoxSr5WGC74gr3WBh6uMNuWBSi13ytqDbYQYmB1wzAviN-Kk_9H3KT41E-iHBRsQXP54RFAYuivMvLG-ZM0whTZ6u8KpVzFZwB2I70kkzuO6EaiNgHC9ebrL_ZW7o__JoV8nBfSpcOqFx5iLgWhZ_p_eOEmGE0fhH_XX7wj6T2bs333P3xixYtnj4GeuyqynJz6Ke3GevI",
                                        provider: .foxid)
            ]
            // swiftlint:enable line_length
    #endif
    }
}
