//
//  DevelopmentThirdPartySSOAuthentication+Extensions.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Haiut on 15/08/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

#if !PUBLIC_DEMO_APP
import Foundation
import OpenWeb_SampleApp_Internal_Configs

extension DevelopmentThirdPartySSOAuthentication {
    func toThirdPartySSOAuthentication() -> ThirdPartySSOAuthentication {
        return ThirdPartySSOAuthentication(displayName: self.displayName,
                                           spotId: self.spotId,
                                           token: self.token,
                                           provider: self.provider)
    }
}

#endif
